#!/usr/bin/python
# -*- coding:utf-8 -*- 
'''
 @Author:      xiaodong
 @Email:       fuxd@jidongnet.com
 @DateTime:    2016-01-05 15:02:30
 @Description: 监控网站主目录php文件
'''


import os
import json
import time
import difflib
from Wechat import sendMessage

def findFile(file_pattern,search_path='.',exclude_dir=None):
	fileList = []
	for root,path,files in os.walk(search_path):
		for f in files:
			if exclude_dir not in root and file_pattern in f :
				fileList.append(os.path.abspath(os.path.join(root,f)))

	return  fileList

	
def compare(filenameOld,filenameNow):

	fOld = file(filenameOld,'r').readlines()
	fNow = file(filenameNow,'r').readlines()
	
	diff = difflib.Differ()
	diff_result = filter(lambda x:  x.startswith('+'),list(diff.compare(fOld,fNow)))
	print diff_result
	return diff_result

def main():
	suffix_date  = time.strftime("%Y%m%d",time.localtime())
	filenameNow = '/tmp/phpfilelist%s.txt' % suffix_date
	filenameOld = '/tmp/phpfilelist.txt'

        search_path = '/data/jidongweb/www.jidongnet.com/'
        exclude_dir = 'cache'
	# 查找 除cache以外所有php文件 
        files = findFile(".php",search_path=search_path,exclude_dir=exclude_dir)
	# 生成当前php文件列表
	file(filenameNow,'w').write('\n'.join(files))

	# 对比文件列表
	diff_result = compare(filenameOld,filenameNow)
	if diff_result:
		# 发送微信报警
		sendMessage('注意！！！ \n 官网服务器 %s  出现新增php文件:\n %s' % ( search_path,map(lambda x:x.split()[1:],diff_result )))
		# 备份后替换OLD文件 消除警报
		os.system('cp /tmp/phpfilelist.txt /tmp/phpfilelist_old%s.txt' % suffix_date)
		file(filenameOld,'w').write('\n'.join(files))
		
	
	
if __name__ == '__main__':
	main()
