#!/usr/bin/python 
#-*- coding: utf-8 -*-
import MySQLdb
import sys
import time,datetime
#reload(sys)
#sys.setdefaultencoding('utf-8')

host = '10.10.41.2'
user = 'root'
password = 'test'
database = 'jd_oss'
result = set([])

now = datetime.datetime.now()
yes_time = now + datetime.timedelta(days=-1)
yes_time = yes_time.strftime('%Y-%m-%d')
print yes_time
select_sql = "select * from dbbackup where dbbackup_time like '%s%%'" % yes_time
#print sql

backup_items = set([#'viet_mysql','viet_redis','viet_mongodb',
	           'dawushi_mysql','dawushi_redis','dawushi_mongodb',
	           'apple_mysql','apple_redis','apple_mongodb',
	       	   'xinchang_redis','xinchang_mysql','xinchang_mongodb',
		   'jidong_mongodb',
              #     'japan_mysql','japan_redis','japan_mongodb',
	           'disney_mysql','disney_redis',
	#	   'taiwan_redis','taiwan_mongodb',
                   ])


db = MySQLdb.connect(host,user,password,database,charset='utf8')
cur = db.cursor()
cur.execute(select_sql)

#for row in cur.fetchall():
#	for i in row:
#		li[i] = li[i].encode('utf-8')
#for row in cur.fetchall():
#	print row
for i in cur.fetchall():
    #print ' '.join(map(str,list(i)))
   # result = ' '.join(map(str,list(i)))
    result.add(''.join(str(i[2])))

#print result
for item in backup_items:
	if item not in result:
		print item + ' backup failed!!' 
		insert_sql = "insert into dbbackup ( \
			      dbbackup_name,dbbackup_dbname,dbbackup_size,dbbackup_type,dbbackup_status,dbbackup_project,dbbackup_dbtype,dbbackup_time) \
			      values('','%s','','','备份失败','','','%s')" % (item,yes_time)
		try:
			cur.execute(insert_sql)
			db.commit()
			print '------- insert done --------'
		except:
			print 'error !!! ======  exit !!'
			db.rollback()
		
	else:
		print item + ' ok!!'
print result
cur.close
