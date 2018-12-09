#/usr/bin/python
import time
import os
from email.MIMEText import MIMEText
from  email.MIMEMultipart import MIMEMultipart
import MySQLdb
import urllib
import urllib2
import cookielib
import smtplib
 
mail_server='smtp.exmail.qq.com'
mail_server_port=25
mail_user='wangdy@jidongnet.com'
mail_password='1qaz9ol.'
 
from_addr='wangdy@jidongnet.com'
to_addr=['wangdy@jidongnet.com','wangdy@jidonggame.com','shenp@jidongnet.com']
 
dbhost='127.0.0.1'
dbuser='root'
dbpasswd='zabbix'
dbport=3306
dbname='zabbix'
 
zabbix_host='zabbix.jidongnet.com'
zabbix_user='Admin'
zabbix_password='jidongzabbixserver'
screen_names=['Dream_Android_Redis_Stats','Dream_Android_Redis_Used_Memory','Dream_IOS_Redis_Stats','Dream_IOS_Redis_Used_Memory']
 
save_graph_path = "/data/zabbix/reports/%s"%time.strftime("%Y-%m-%d")
if not os.path.exists(save_graph_path):
    os.makedirs(save_graph_path)
 
width=600
height=100
period=86400
 
def send_email(sub,content):
    m=MIMEMultipart()
    m["To"]=";".join(to_addr)
    m["From"]=from_addr
    m["Subject"]=sub
    m.attach(MIMEText(content,_subtype="html",_charset="utf8"))
 
    s=smtplib.SMTP(mail_server,mail_server_port)
#    s.set_debuglevel(1)
    s.login(mail_user,mail_password)
    s.sendmail(from_addr,to_addr,m.as_string())
    s.quit()
 
def mysql_query(sql):
    db=MySQLdb.connect(host=dbhost,user=dbuser,passwd=dbpasswd,port=dbport,db=dbname,connect_timeout=20)
    cur=db.cursor()
    try:
        count=cur.execute(sql)
        if count==0:
            result=0
        else:
            result=cur.fetchall()
        return result
        cur.close()
        conn.close()
    except MySQLdb.Error,e:
        print "mysql error:" ,e
 
def get_graph(zabbix_host,zabbix_user,zabbix_password,screen,width,height,period,save_graph_path):
    screenid_list = []
    global html
    html = ''
    for i in mysql_query("select screenid from screens where name='%s'"%(screen)):
                for screenid in i:
                    graphid_list = []
                    for c in mysql_query("select resourceid from screens_items where screenid='%s'"%(int(screenid))):
                        for d in c:
                            graphid_list.append(int(d))
                    for graphid in graphid_list:
                        login_opt = urllib.urlencode({
                        "name": zabbix_user,
                        "password": zabbix_password,
                        "autologin": 1,
                        "enter": "Sign in"})
                        get_graph_opt = urllib.urlencode({
                        "graphid": graphid,
                        "screenid": screenid,
                        "width": width,
                        "height": height,
                        "period": period})
                        cj = cookielib.CookieJar()
                        opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
                        login_url = r"http://%s/index.php"%zabbix_host
                        save_graph_url = r"http://%s/chart2.php"%zabbix_host
                        opener.open(login_url,login_opt).read()
                        data = opener.open(save_graph_url,get_graph_opt).read()
                        filename = "%s/%s.%s.png"%(save_graph_path,screenid,graphid)
                        html += '<img width="600" height="250" src="http://%s/%s/%s/%s.%s.png">'%(zabbix_host,save_graph_path.split("/")[len(save_graph_path.split("/"))-2],save_graph_path.split("/")[len(save_graph_path.split("/"))-1],screenid,graphid)
                        f = open(filename,"wb")
                        f.write(data)
                        f.close()
 
if __name__ == '__main__':
    for screen in screen_names:
        get_graph(zabbix_host,zabbix_user,zabbix_password,screen,width,height,period,save_graph_path)
        send_email(screen,html)

