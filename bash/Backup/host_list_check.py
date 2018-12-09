#!/usr/bin/env python
# -*- coding:utf-8 -*-
import MySQLdb
import simplejson as json
import os,sys
#import chardet
#接收人员,RTX标识id 使用','分隔
#recevier = '1192,1063,1189'
recevier = '1192'

#获取oss mysql中的相关主机信息
host = '10.10.41.2'
user = 'root'
password = 'test'
database = 'jd_oss'
mysql_result = []
sql = "select * from machine where machine_platform='Ucloud'"
db = MySQLdb.connect(host,user,password,database,charset='utf8')
cur = db.cursor(cursorclass=MySQLdb.cursors.DictCursor)
cur.execute(sql)
info = cur.fetchall()
for host in info:
	mysql_result.append(host)
cur.close()
db.close()

ucloud_private_ip = ""
ucloud_unicom_ip = ""
ucloud_telecom_ip = ""
oss_private_ip = ""
oss_unicom_ip = ""
oss_telecom_ip = ""

jsonobject = json.load(file('uhost_list.json'))
print jsonobject
sys.exit()


for host in range(0,len(jsonobject["UHostSet"])):
	print '------- %d  -----------' % host
	host_info = jsonobject["UHostSet"][host]["IPSet"]
	remark = jsonobject["UHostSet"][host]["Remark"]
	print "host number: %d " % host
	print "host remark: %s " % remark
	#获取json格式的Ucloud相关ip信息
	try:
		ucloud_private_ip = jsonobject["UHostSet"][host]["IPSet"][0]['IP']
		ucloud_unicom_ip = jsonobject["UHostSet"][host]["IPSet"][1]['IP']
		ucloud_telecom_ip = jsonobject["UHostSet"][host]["IPSet"][2]['IP']
	except IndexError,NameError:
		pass

	#获取mysql对应主机信息
	for oss_host in range(0,len(mysql_result)):
		res = mysql_result[oss_host]['machine_func'].encode('utf-8')
		status = res.find(remark.encode('utf-8')) 
	#	print '%s ------  %s  ------- %s -------- %s' % (oss_host,res,status,remark.encode('utf-8'))
		if status != -1:
			oss_private_ip = mysql_result[oss_host]['machine_localip']
			oss_unicom_ip = mysql_result[oss_host]['machine_cncip']
			oss_telecom_ip = mysql_result[oss_host]['machine_telip']
	#	print chardet.detect(res_real)
			print '======  index %s' % remark
			print '======  result %s' % res
			print '====== oss private ip %s ----  ucloud private ip %s' % (oss_private_ip,ucloud_private_ip)
			print '====== oss unicom ip %s ----  ucloud unicom ip %s' % (oss_unicom_ip,ucloud_unicom_ip)
			print '====== oss telecom ip %s ----  ucloud telecom ip %s' % (oss_telecom_ip,ucloud_telecom_ip)
			
			if cmp(ucloud_private_ip,oss_private_ip) == -1 or cmp(ucloud_unicom_ip,oss_unicom_ip) == -1 or cmp(ucloud_telecom_ip,oss_telecom_ip) == -1:
				#for ip_info in range(0,len(jsonobject["UHostSet"][host]["IPSet"])):
				#	print jsonobject["UHostSet"][host]["IPSet"][ip_info]['IP'] + " ",
				#print oss_private_ip +"  "+ oss_unicom_ip + " " + oss_telecom_ip
				error =   '''%s : oss和ucloud ip数据不一致!\nUcloud: %s\t%s\t%s\nOSS:%s\t%s\t%s ''' % (remark.encode('utf-8'),ucloud_private_ip.encode('utf-8'),ucloud_unicom_ip.encode('utf-8'),ucloud_telecom_ip.encode('utf-8'),oss_private_ip.encode('utf-8'),oss_unicom_ip.encode('utf-8'),oss_telecom_ip.encode('utf-8'))
				print error	
				os.system('python /script/account_tools/SendRTX.py -s 10.10.41.58:8012 -u %s -m "%s"'% (recevier,error))
			else:
				print 'ok'
