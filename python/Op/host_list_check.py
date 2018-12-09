#!/usr/bin/env python
# -*- coding:utf-8 -*-
import MySQLdb
import simplejson as json
import os,sys
import urllib

#import chardet

def get_mysql(sql):
    host = '10.10.41.2'
    user = 'root'
    password = 'test'
    database = 'jd_oss'
    try:
        db = MySQLdb.connect(host,user,password,database,charset='utf8')
        cur = db.cursor(cursorclass=MySQLdb.cursors.DictCursor)
        cur.execute(sql)
        mysql_result = cur.fetchall()
    except Exception, e:
        print e
        mysql_result = None
    cur.close()
    db.close() 
    return mysql_result

def get_ucloud_host_info(datacenters):  
    ucloud_host_info = []
    for datacenter in datacenters: 
        ucloud_host_info.extend(json.load(os.popen('python /data/tools/ucloud_sdk/python-sdk-v2-master/describe_uhost_instance.py %s' % datacenter ))['UHostSet'])
    return ucloud_host_info

def sendrtx(error,recevier): 
    recivers = ','.join(recevier)
    hostname = os.popen('hostname').read()
    MESSAGE = error.decode('utf-8').encode('gb2312')
    urllib.urlopen('http://101.231.68.46:8012/sendnotify.cgi?msg='+MESSAGE+'&receiver='+recivers+'&title='+hostname)

#对比所有机器数据 筛选重复项
def oss_repeat_check():
    sql = "select * from machine"
    mysql_result = get_mysql(sql)
    #获取表字段
    #oss_row_name = mysql_result[0].keys()
    '''['machine_id',
         'machine_vm',
         'machine_project',
         'machine_status',
         'machine_bgpip',
         'machine_platform',
         'machine_func',
         'machine_telip',
         'machine_localip',
         'machine_cncip']
     '''
    #需要统计重复的表字段
    oss_row_name = ['machine_bgpip', 'machine_telip', 'machine_localip', 'machine_cncip']

    for row in iter(oss_row_name):
        errors = []
        #遍历获取表中某一字段的所有值
        row_datas = [i[row] for i in mysql_result ] 
        uniq_datas = [ i for i in list(set(row_datas)) if i != '' ]
        for row_data in uniq_datas:
            count = row_datas.count(row_data) 
            if count > 1:
                error = ("oss 出现重复:\n字段:  %s\n值：   %s\n重复次数：%i\n" % (row.encode('utf-8'),row_data.encode('utf-8'),count))
                errors.append(error)
        return errors




if __name__ == '__main__':

    '''
    数据中心列表 Region :
    北京BGP-A       cn-north-01     Bgp: BGP线路
    北京BGP-B       cn-north-02     Bgp: BGP线路
    北京BGP-C       cn-north-03     Bgp: BGP线路
    华东双线        cn-east-01      Duplet: 双线, Unicom: 网通, Telecom: 电信
    华南双线        cn-south-01     Duplet: 双线, Unicom: 网通, Telecom: 电信
    亚太            hk-01           International: 国际线路
    北美            us-west-01      International: 国际线路
    '''
    #Ucloud机房
    datacenters = ['cn-east-01','cn-north-03']
    #####  rtx接收人  ######
    recevier = ['1192']

    #检查oss是否有重复字段
    repeat_check_reuslt = oss_repeat_check()
    if len(repeat_check_reuslt) > 0:
        (lambda errors: [ sendrtx(error,recevier) for error in repeat_check_reuslt ])(repeat_check_reuslt)


    ##### mysql 相关 ####

    sql = "select * from machine where machine_platform='Ucloud'"

    ucloud_host_info = get_ucloud_host_info(datacenters)

    oss_host_info = get_mysql(sql)
    #oss_description = [ h['machine_func'] for h in oss_host_info ]
    oss_private_ips = map(lambda a:a.strip(),[ h['machine_localip'] for h in oss_host_info ])

    for host in range(0,len(ucloud_host_info)):
        host_info = ucloud_host_info[host]["IPSet"]
        ucloud_host_remark = ucloud_host_info[host]["Name"]
        print '\033[31m ** %s **\033[0m 对比开始....' % ucloud_host_remark.encode('utf-8')

        ucloud_private_ip = ucloud_host_info[host]["IPSet"][0]['IP']
        if len(ucloud_host_info[host]["IPSet"]) == 1:
            ucloud_unicom_ip = ''
            ucloud_telecom_ip = ''
        else:
            if ucloud_host_info[host]["IPSet"][1]["Type"] == 'Bgp':
                ucloud_bgp_ip = ucloud_host_info[host]["IPSet"][1]['IP']
            elif len(ucloud_host_info[host]["IPSet"]) == 2:
                ucloud_unicom_ip = ucloud_host_info[host]["IPSet"][1]['IP']
            elif len(ucloud_host_info[host]["IPSet"]) == 3:
                ucloud_unicom_ip = ucloud_host_info[host]["IPSet"][1]['IP']
                ucloud_telecom_ip = ucloud_host_info[host]["IPSet"][2]['IP']

        if ucloud_private_ip not in oss_private_ips:
            try:
                if ucloud_bgp_ip :
                    error = '''运维平台缺少云主机信息：
主机：%s
内网：%s
BGP:  %s
''' % ( ucloud_host_remark.encode('utf-8'),
        ucloud_private_ip.encode('utf-8'),
     ucloud_bgp_ip.encode('utf-8')
    )
            except NameError,e:
                    error = '''运维平台缺少云主机信息：
主机: %s       
内网：%s  
电信: %s 
联通：%s 
''' % (ucloud_host_remark.encode('utf-8'),
        ucloud_private_ip.encode('utf-8'),
        ucloud_unicom_ip.encode('utf-8'),
        ucloud_telecom_ip.encode('utf-8')
        )

            sendrtx(error,recevier)
            continue
        else:   
            oss_host_pos = oss_private_ips.index(ucloud_private_ip)     
            oss_unicom_ip = oss_host_info[oss_host_pos]['machine_cncip']
            oss_telecom_ip = oss_host_info[oss_host_pos]['machine_telip']
            oss_bgp_ip = oss_host_info[oss_host_pos]['machine_bgpip']
            try:
               if ucloud_bgp_ip:
                    if cmp(ucloud_bgp_ip.strip(),oss_bgp_ip.strip()) : 
                        error =   '''%s : oss和ucloud ip数据不一致! 
                        Ucloud: %s\t%s
                        OSS: %s\t%s''' % (ucloud_host_remark.encode('utf-8'),
                            ucloud_private_ip.encode('utf-8'),ucloud_bgp_ip.encode('utf-8'),
                            ucloud_private_ip.encode('utf-8'),oss_bgp_ip.encode('utf-8'))
            except NameError, e:
                if  cmp(ucloud_unicom_ip.strip(),oss_unicom_ip.strip()) or cmp(ucloud_telecom_ip.strip(),oss_telecom_ip.strip()): 
                    error =   '''%s : oss和ucloud ip数据不一致!请检查..注意电信和网通ip的顺序
Ucloud: %s\t%s\t%s
OSS:   %s\t%s\t%s 
                    ''' % (ucloud_host_remark.encode('utf-8'),
                        ucloud_private_ip.encode('utf-8'),ucloud_unicom_ip.encode('utf-8'),ucloud_telecom_ip.encode('utf-8'),
                        ucloud_private_ip.encode('utf-8'),oss_unicom_ip.encode('utf-8'),oss_telecom_ip.encode('utf-8'))
                    sendrtx(error,recevier)
                    print error 
    print '对比完成.!'