#/usr/bin/python

import os
import subprocess
import redis
import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
import socket

#get the localhost name
hostname=socket.gethostname()

mail_server='mail.jidonggame.com'
mail_server_port=25
mail_user='sengoku_bi@jidonggame.com'
mail_password='jidongnet.550'

from_addr='sengoku_bi@jidonggame.com'
to_addr=['shenp@jidonggame.com','fuxd@jidongnet.com']

#define send_email function for reuse
def send_email(sub,content):
    m=MIMEMultipart()
    m["To"]=";".join(to_addr)
    m["From"]=from_addr
    m["Subject"]=sub
    m.attach(MIMEText(content))
       
    s=smtplib.SMTP(mail_server,mail_server_port)
#    s.set_debuglevel(1)
    s.login(mail_user,mail_password)
    s.sendmail(from_addr,to_addr,m.as_string())
    s.quit()


redis_host='redis.mcdfucxp.scs.bj.baidubce.com'
redis_port='6379'
redis_db='db'
try:
   r=redis.StrictRedis(host=redis_host, port=redis_port, db=redis_db,socket_timeout=1)
   bi_length=r.llen('bi')
   if bi_length > 1000:
    #  url_list=r.lrange('bi',0,0)
      warning_subject="BI KEY WARING ON "+hostname
      warning_message=redis_host + ':' + redis_port + ' ' + redis_db +  " The bi key's length is greater than 100" + '\n' + "URL: " + str(bi_length) 
      send_email(warning_subject,warning_message) 
   else:
      print 'bi length : %s' % bi_length
except redis.exceptions.ConnectionError:
      connect_subject="Connect to redis server on "+hostname+" error"
      connect_error="Connect to redis server " + redis_host + ":" +  redis_port  +  "  error"
      send_email(connect_subject,connect_error)
except redis.exceptions.ResponseError:
      response_subject="Redis server response error on " + hostname
      response_error="Redis server response error " + redis_host + ":" + redis_port + " db: " + redis_db
      #send_email(response_subject,response_error)
 
