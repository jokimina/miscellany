#!/usr/bin/env python
#encoding:utf8
import urllib2
import json
import sys
class weChat(object):
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
        '''
        : userlist 多个用户使用 '|'  分隔. 推送所有已关注用户 @all
        : content  发送的文本内容
        : agentid  0 业务报警 1 安全报警
        '''
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

def main():
      #userlist = sys.argv[1]
      content = sys.argv[1:]
      content = '\n'.join(content)
      Corpid = 'wxf2176a593f7d8350'
      Secret = 'FRVQ4_A7N4jMmq4kAyVzKFd5TYajP3A_hmYrWYSR6ofrCo8HA_A9TkDxS0_8z_wZ'
      url = 'https://qyapi.weixin.qq.com'

      userlist = "xiaodongplay|wangzhanglei" # 多个用户 "|" 分割
      wechat = weChat(url,Corpid,Secret)
      wechat.send_message(userlist, content, 1)



if __name__ == '__main__':
      main()
