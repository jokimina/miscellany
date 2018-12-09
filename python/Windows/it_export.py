#-*- coding:utf-8 - * -
import MySQLdb
import sys,os
from openpyxl import Workbook
import chardet
import time


def get_mysql(sql):
    host = '10.10.41.2'
    user = 'root'
    password = 'test'
    database = 'jd_oss'
    try:
        db = MySQLdb.connect(host,user,password,database,charset='utf8')
        cur = db.cursor(cursorclass=MySQLdb.cursors.DictCursor)
        cur.execute(sql)
        mysql_result = cur.fetchall()
    except Exception, e:
        print e
        mysql_result = None
    cur.close()
    db.close() 
    return mysql_result

    

def to_excel(title,content,filename,sortFlied):
	wb = Workbookzz	
	ws = wb.active
	ws.append(title)
	for row in iter(content):
		ws.append(row)
	export_time =  time.strftime("%Y%m%d",time.localtime())
	filename = filename + export_time + '.xlsx'
	if sys.platform == 'win32':
		wb.save(filename.decode('utf-8').encode('gbk'))
	else:
		wb.save(filename)
	return os.getcwd() + os.sep +filename

if __name__ == '__main__':

	nameMapper = {
		'it_id'			: '编号',
		'it_serial'		: '序列号',
		'it_type'		: '资产类型',
		'it_size'		: '型号/尺寸',
		'it_brand'		: '品牌',
		'it_os'			: '系统',
		'it_cpu'		: 'CPU',
		'it_mem'		: '内存',
		'it_ip'			: 'IP',
		'it_mac'		: 'MAC地址',
		'it_dep'		: '部门',
		'it_user'		: '使用者',
		'it_status'		: '状态',
		'it_reason'		: '使用原因',
		'it_usetime'	: '使用时间',
		'it_buytime'	: '购买时间',
		'it_cost'		: '价格',
		'it_channel'	: '购买渠道',
		'it_detail'		: '细节',
		'it_dec'		: '详细信息'
	}
	#按照此顺序进行排列导出指定字段
	sortFlied = ['it_id','it_user','it_type','it_dep','it_size','it_serial','it_status','it_brand','it_cost','it_reason','it_buytime','it_channel','it_ip','it_dec']

	sql = 'select ' + ','.join(sortFlied) + ' from it'
	content = []
	filename = 'IT管理列表'
	
	mysql_result = get_mysql(sql)
	if mysql_result:
		title = [ nameMapper[t] for t in sortFlied ]
		for num in range(len(mysql_result)):
			content.append([ mysql_result[num][f] for f in sortFlied ])
			# content.append(mysql_result[num].values())
	print content
	sys.exit()


	filepath = to_excel(title,content,filename,sortFlied)
	print '文件导出位置：' + filepath








