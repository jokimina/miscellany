#!/usr/bin/python
#coding=utf-8
import os
import time
import sys
import re
import pycurl
import urllib2
import simplejson as json
import chardet
reload(sys)
sys.setdefaultencoding('utf-8')# sys.exit(sys.getdefaultencoding())

def get_file(rootDir, keyFile):
    list_dirs = os.walk(rootDir)
    filelist = []
    # 遍历查找关键文件
    for root, dirs, files in list_dirs:
        for d in files:
            if keyFile in d:
                filelist.append(os.path.join(root, d))
    try:
        file_status = [(name, os.path.getmtime(name)) for name in filelist]
	file_status.sort(key=lambda x:x[1],reverse=True)
        # print file_status[0][1]
        File, Time = file_status[0]
        Time = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(file_status[0][1]))
    except Exception, e:
        sys.exit('没有找到文件: "%s"' % keyFile)

    print Time,File
    return File, Time


def get_TestUrl(base_cdn_url, File, keyDir):
    url_suffix = re.findall(r'%s.*' % keyDir, File)[0]
    url_suffix = re.sub(r'\\', '/', url_suffix)
    test_url = base_cdn_url + url_suffix
    return test_url

#使用pycurl进行检测
def url_Check(test_url):
    result = {}
    #初始化参数列表
    c = pycurl.Curl()
    c.setopt(pycurl.URL,test_url)
    c.setopt(pycurl.CONNECTTIMEOUT,100) #请求连接等待时间
    c.setopt(pycurl.TIMEOUT,5)        #请求连接超时时间
    c.setopt(pycurl.NOPROGRESS,1)      #屏蔽下载进度条
    c.setopt(pycurl.FORBID_REUSE,1)         #完成后断开连接,不重用
    c.setopt(pycurl.MAXREDIRS,1)      #指定HTTP重定向的最大数为1
    c.setopt(pycurl.DNS_CACHE_TIMEOUT,30)     #保存DNS信息时间为30秒

    #保存请求内容到当前目录
    # indexfile = open(os.path.dirname(os.path.relpath(__file__)) + test_url.split('/')[-1] ,'wb')
    # c.setopt(pycurl.WRITEDATA,indexfile)
   # c.setopt(pycurl.WRITEHEADER,open('C:\Users\Administrator\Desktop\head.html','wb'))

    #开始请求
    try:
      c.perform()
    except Exception, e:
      print "connection error:" + str(e)
      # indexfile.close()
      c.close()

    result['test_url'] = test_url
    result['NAMELOOKUP_TIME'] = c.getinfo(c.NAMELOOKUP_TIME)
    result['CONNECT_TIME'] = c.getinfo(c.CONNECT_TIME)
    result['PRETRANSFER_TIME'] = c.getinfo(c.PRETRANSFER_TIME)
    result['STARTTRANSFER_TIME'] = c.getinfo(c.STARTTRANSFER_TIME)
    result['TOTAL_TIME'] = c.getinfo(c.TOTAL_TIME)
    result['HTTP_CODE'] = c.getinfo(c.HTTP_CODE)
    result['SIZE_DOWNLOAD'] = c.getinfo(c.SIZE_DOWNLOAD)
    result['HEADER_SIZE'] = c.getinfo(c.HEADER_SIZE)
    result['SPEED_DOWNLOAD'] = c.getinfo(c.SPEED_DOWNLOAD)

    # indexfile.close()
    c.close()
    return result

#微信发送类
class weChat:

    def __init__(self, url, Corpid, Secret):
        url = '%s/cgi-bin/gettoken?corpid=%s&corpsecret=%s' % (
            url, Corpid, Secret)
        res = self.url_req(url)
        self.token = res['access_token']

    def url_req(self, url, method='get', data={}):
        if method == 'get':
            req = urllib2.Request(url)
            res = json.loads(urllib2.urlopen(req).read())
        elif method == 'post':
            req = urllib2.Request(url, data)
            res = json.loads(urllib2.urlopen(req).read())
        else:
            print 'error request method...exit'
            sys.exit()
        return res

    def send_message(self, userlist, content, agentid=0):
        self.userlist = userlist
        self.content = content
        url = 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=%s' % self.token
        data = {
            "touser": "",
            "toparty": "",
            "totag": "",
            "msgtype": "text",
            "agentid": "0",
            "text": {
                "content": ""
            },
            "safe": "0"
        }
        data['touser'] = userlist
        data['agentid'] = agentid
        data['text']['content'] = content
        #print data
        data = json.dumps(data,ensure_ascii=False)
        data = str(data)
        res = self.url_req(url, method='post', data=data)
        if res['errmsg'] == 'ok':
            print 'send sucessed!!!'
        else:
            print 'send failed!!'
            print res

def refresh_ucdn_cache():
    pass

if __name__ == '__main__':
    #rootDir = 'e:\my_python'
    rootDir = '/data/cdn_data/gintama/'
    keyFile = 'check_file.json'
    keyDir = 'gintama'
    base_cdn_url = 'http://gmcdn.youxi021.com/'

    #File,Time = get_file(rootDir,keyFile)
    #test_url = get_TestUrl(base_cdn_url, File, keyDir)
    #test_url = 'http://pirates.i.dol.cn/itunes/pirates/resources/ios/1.0.9.921/checksum.json'
    test_url = 'http://vpc-gaia.c5c6490e0206b4d5a9f8a6ff68de1ca62.cn-beijing.alicontainer.com:8080/getUserPhoneSmsRecords?phone=15880249391&userId=2396507&cutoffTime=2016-08-07+17:11:07&mtk=c37aa25824cd43d7021d81a0e730b3cf'

    result = url_Check(test_url) 
    result_data = '''请求地址：%s
HTTP 状态码： %s 
DNS解析时间:  %.2f ms 
建立连接时间: %.2f ms
准备传输时间: %.2f ms
传输开始时间: %.2f ms 
传输结束总时间： %.2f ms
下载数据包大小： %d bytes/s
HTTP 头部大小 ： %d bytes
平均下载速度 ：  %d bytes/s 
    ''' % (
           result['test_url'],
           result['HTTP_CODE'],
           result['NAMELOOKUP_TIME'] * 1000,
           result['CONNECT_TIME'] * 1000,
           result['PRETRANSFER_TIME'] * 1000,
           result['STARTTRANSFER_TIME'] * 1000,
           result['TOTAL_TIME'] * 1000,
           result['SIZE_DOWNLOAD'],
           result['HEADER_SIZE'],
           result['SPEED_DOWNLOAD'])
#    print chardet.detect(result_data)
    print result_data
    #微信参数
    # Corpid = 'wx7ec62bf5b6beaa80'
    # Secret = 'GkniOucrQSiDYnHi4HZ8u1Fd8AuJaoUQrtA1Wbc7JNYoNNqWMsLDIgvHLH7XSyWU'
    # url = 'https://qyapi.weixin.qq.com'
    # userlist = 'xiaodong'

    # wechat = weChat(url, Corpid, Secret)
    #wechat.send_message(userlist, result_data)








