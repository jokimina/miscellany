#!/usr/bin/env python
#encoding:utf8
import urllib2
import simplejson as json
import sys
import os 
import pypinyin
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

class weChat:
    def __init__(self,url,Corpid,Secret): 
        url = '%s/cgi-bin/gettoken?corpid=%s&corpsecret=%s' % (url,Corpid,Secret)
        self.url = url
        res = self.url_req(url)
        self.token = res['access_token']

    def url_req(self,url,method='get',data={}):
        if method == 'get':
            req = urllib2.Request(url)
            res = json.loads(urllib2.urlopen(req).read())
        elif method == 'post':
                        req = urllib2.Request(url,data)
                        res = json.loads(urllib2.urlopen(req).read())
        else:
            print 'error request method...exit'
            sys.exit()  
        return res

    def get_department(self):
        url = "https://qyapi.weixin.qq.com/cgi-bin/department/list?access_token=%s&id=0" % self.token
        return self.url_req(url)


    def get_department_users(self,department_id,fetch_child=1,status=0):
        '''
        department_id = 0            部门id                                                                                                    
        fetch_child = 1              是否递归子部门 1/0                                                                                        
        status = 0                   0获取全部成员，1获取已关注成员列表，2获取禁用成员列表，4获取未关注成员列表。status可叠加，未填写则默认为0
        '''
        url = "https://qyapi.weixin.qq.com/cgi-bin/user/simplelist?access_token=%s&department_id=%s&fetch_child=%s&status=%s" % (
            self.token,department_id,fetch_child,status)
        return self.url_req(url)

    def send_message(self,userlist,content,agentid=0):
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
                      "safe":"0"
                   } 
        data['touser'] = userlist   
        data['agentid'] = agentid
        data['text']['content'] = content
        data = json.dumps(data,ensure_ascii=False)
    #   print data
        res = self.url_req(url,method='post',data=data)
        if res['errmsg'] == 'ok':
            print 'send sucessed!!!'
        else:
            print 'send failed!!'
            print res
        
    def trans_pinyin(self,strings):
      return ''.join(pypinyin.lazy_pinyin(strings,errors='ignore'))
                
        
if __name__ == '__main__':  
        #userlist = sys.argv[1]
        #content = sys.argv[2:]
        #content = '\n'.join(content)
        Corpid = 'wx2e73e37a04685fb8'
        Secret = 'ovHP_mJ9_0T0-DDyYvQLX1UbhzsBTM2Zeo-YlB9ioM3vDpe0Qo4KptCPr3LzpvBZ'
        url = 'https://qyapi.weixin.qq.com'
        
        wechat = weChat(url,Corpid,Secret)

        # print json.dumps(wechat.get_department(),indent=2,ensure_ascii=False)
        # sys.exit()
        # print wechat.url
        # print wechat.token
        # print json.dumps(wechat.get_department(),ensure_ascii=False,indent=2)
        users = []
        names = []
        # users.extend(wechat.get_department_users(23)["userlist"])
        users.extend(wechat.get_department_users(40)["userlist"])
        users.extend(wechat.get_department_users(18)["userlist"])
  
        names = [ wechat.trans_pinyin(name["name"]) for name in users  ]
        names = [ name for name in names if name != '' and len(name) < 20 ]

        for user in users :
            print user
            name = wechat.trans_pinyin(user["name"]) 
            if name != '' and len(name) < 20 :
                os.system('net user  %s %s /add' % (name,'123'))
                os.system('net localgroup wifi %s  /add' % name)
            else:
                print 

        
        # print json.dumps(users,ensure_ascii=False,indent=2)


