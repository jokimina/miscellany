#!/user/bin python
# -*- coding:utf-8 -*- 
'''
 @Author:      xiaodong
 @Email:       fuxd@jidongnet.com
 @DateTime:    2015-12-16 17:01:58
 @Description: 加勒比 安卓平台遍历全区 搜索100W以上钻石的玩家
'''

import redis
import sys
import json

redisList = [6510,6520,6530,6540,6541,6542,6543,6544,6545,6546,6547,6548,6549,6550,6551,6552,6553,6554,6555,6556,6557,6558,6559,6560,6561,6562,6563,6564,6565,6566,6567,6568,6569]
hostList = ['192.168.1.190','192.168.1.187','192.168.1.188','192.168.1.189']


for redis_port in redisList:
	rightRole = []
	host_index =  int(str(redis_port)[2:]) % 4
	host = hostList[host_index]	
	print redis_port ,'---',host

	r =  redis.StrictRedis(host=host,port=redis_port,db=3)
	# 过滤掉机器人
	allRoles = filter(lambda x:len(x) > 6,r.keys('r_*'))
	# 开始过滤 钻石数大于100W
	for role in allRoles:	
		roleInfo = []
		roleInfo = r.hmget(role,'name','cash')
		if int(roleInfo[1]) > 1000000:
			roleInfo.append(role[-2:])
			rightRole.append(roleInfo)
	f = file('role_100W_%s.txt'%redis_port,'w+')
	f.write('\n'.join([ ' -- '.join(i) for i in rightRole]))
	f.flush()
	f.close()
