#!/usr/bin/python
# coding : utf-8
import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from email.Header import Header
import sys
reload(sys)
sys.setdefaultencoding('utf-8')


# define send_email function for reuse
def send_email(sub, content, filename='',mail_type='html'):
        m = MIMEMultipart()
        m["To"] = ";".join(to_addr)
        m["From"] = from_addr
        m["Subject"] = Header(sub,'utf-8')

        # m["Accept-Language"]="zh-CN"
        # m["Accept-Charset"]="ISO-8859-1,utf-8"
        text = MIMEText(content,mail_type,'utf-8')
        m.attach(text)

        s = smtplib.SMTP(mail_server, mail_server_port)
        if filename:
            att = MIMEText(open(filename, 'rb').read(), 'base64', 'gb2312')
            att["Content-Type"] = 'application/octet-stream'
            att["Content-Disposition"] = 'attachment; filename="%s"' % filename.encode('gb2312')
            m.attach(att)
        #    s.set_debuglevel(1)
        s.login(mail_user, mail_password)
        try:
            s.sendmail(from_addr, to_addr, m.as_string())
            print 'send sucessed!'
        except Exception, e:
            print 'send failed!'
            print str(e)
        s.quit()

if __name__ == '__main__':
    mail_server = 'smtp.exmail.qq.com'
    mail_server_port = 25
    mail_user = 'fuxiaodong@xxxxx.com'
    mail_password = 'xxxx'
    from_addr = 'fuxiaodong@xxxxx.com'
    to_addr = [sys.argv[1]]
    sub = sys.argv[2]
    content = '\n'.join(sys.argv[2:])
    send_email(sub,content)
