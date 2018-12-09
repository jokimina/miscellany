#/usr/bin/python
#-*- coding:utf-8 -*-
#发送每月资产列表
import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from email.Header import Header 
import datetime
import sys,os
from openpyxl import load_workbook 
import chardet
# get the localhost name

mail_server = 'mail.jidonggame.com'
mail_server_port = 25
mail_user = 'op@jidonggame.com'
mail_password = 'xxxxxxxxx'
from_addr = 'op@jidonggame.com'
to_addr = [ 'op@jidonggame.com', 'fuxd@jidongnet.com']

# define send_email function for reuse
def send_email(sub, content, filename):
	m = MIMEMultipart()
	m["To"] = ";".join(to_addr)
	m["From"] = from_addr
	m["Subject"] = Header(sub,'utf-8')

	# m["Accept-Language"]="zh-CN"
	# m["Accept-Charset"]="ISO-8859-1,utf-8"
	text = MIMEText(content,'html','utf-8')
	m.attach(text)

	s = smtplib.SMTP(mail_server, mail_server_port)
	att = MIMEText(open(filename, 'rb').read(), 'base64', 'gb2312')
	att["Content-Type"] = 'application/octet-stream'
	att["Content-Disposition"] = 'attachment; filename="%s"' % filename.encode('gb2312') 
	m.attach(att)
	#    s.set_debuglevel(1)
	s.login(mail_user, mail_password)
	try:
	    s.sendmail(from_addr, to_addr, m.as_string())
	    print u'发送成功'
	except Exception, e:
	    print u'发送失败！'
	    print str(e)
	s.quit()


def get_new_content(filename):
	''' 生成新增资产表 '''
	content = []

	filename = unicode(filename,'utf-8')
	wb = load_workbook(filename)
	ws = wb.get_sheet_by_name(wb.get_sheet_names()[-1])
	if len(ws.rows) <= 2:
		s = u'<h3>上月无新增资产.</h3>'
	else:
		head = [ a.value for a in ws.rows[1] ] 
		for row in ws.rows[2:]:
			content.append([ cell.value for cell  in row ])

		s = ' <table border="1" cellspacing="0" cellpadding="10"> <tr> ' 
		for h in head :
			s += '<th> %s </th>' % h
		s += '</tr>'
		for c in content:
			s+='<tr>' 
			for i in c:
				s+='<td>%s</td>' % i
			s+='</tr>'
		s+='</table>'
	return s

if __name__ == '__main__':
	# head,content = get_new_content()
	filename = os.popen('it_export_v3.py').read().split(os.sep)[-1].strip()
	s = get_new_content(filename)

	today = datetime.date.today()
	month = today.month
	sub = str(month) + u'月固定资产'
	content = u''' 
<h3>各位领导：</h3>
<h3>&nbsp;&nbsp;  上午好！截止%d月%d号,新增固定资产如下，具体详细信息请查看附件。</h3>
''' % (today.month,today.day)
	content = content + '\n' + s


	send_email(sub,content,filename)


 