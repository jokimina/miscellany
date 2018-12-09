#!/usr/bin/env python
# -*- coding: utf-8 -*-

import smtplib
import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage

serv_address = 'smtp.qq.com'
from_address = 'root@yhsafe.net'
toaddresslst = '1784763743@qq.com'
mail_subject = ''.join([unicode(datetime.datetime.now()), u'华东 - 业务性能数据报表'])

def addimage(imgsrc, imgid):
	with open(imgsrc, 'rb') as image_bin:
		mail_image = MIMEImage(image_bin.read())
	mail_image.add_header('Content-ID', imgid)
	return mail_image

def addattach(fpath, encode):
	with open(fpath, 'rb') as attach_bin:
		mail_attach = MIMEText(attach_bin.read(), 'base64', 'utf-8')
	mail_attach.add_header('Content-Type', 'application/octet-stream')
	mail_attach.add_header('Content-Disposition', 'attachment;filename="华东 - 本周性能数据表.xlsx"'.decode('utf-8').encode(encode))
	return mail_attach

mail_message = MIMEMultipart('related')
mail_text = MIMEText('''\
<table border="0" cellspacing="0" cellpadding="4">
	<tr bgcolor="#CECFAD" height="20px" style="font-size:14px" >
		<td colspan="2">* 华东 - 性能数据 <a href="pythonweb.blog.163.com">&gt;&gt;更多</a></td>
	</tr>
	<tr bgcolor="#EFEBDE" hieght="171" style="font-size:13px">
		<td><img src="cid:mem"></td>
		<td><img src="cid:load"></td>
	</tr>
	<tr bgcolor="#EFEBDE" height="171" style="font-size:10px">
		<td><img src="cid:net"></td>
		<td><img src="cid:cpu"></td>
	</tr>
</table>''', 'html', 'utf-8')

mail_message.attach(mail_text)
mail_message.attach(addimage('./mem.png', 'mem'))
mail_message.attach(addimage('./load.png', 'load'))
mail_message.attach(addimage('./net.png', 'net'))
mail_message.attach(addimage('./cpu.png', 'cpu'))
mail_message.attach(addattach('./week_report.xlsx', 'gb18030'))
mail_message['Subject'] = mail_subject
mail_message['From'] = from_address
mail_message['To'] = toaddresslst
try:
	mail = smtplib.SMTP()
	mail.connect(serv_address, '25')
	mail.starttls()
	mail.login('email_user', 'email_pass')
	mail.sendmail(from_address, toaddresslst, mail_message.as_string())
	mail.quit()
except Exception as Error:
	print 'Found Error: {0}'.format(Error)