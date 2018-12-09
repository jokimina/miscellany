#!/user/bin python
# -*- coding:utf-8 -*- 
'''
 @Author:      xiaodong
 @Email:       fuxd@jidongnet.com
 @DateTime:    2015-12-03 17:09:42
 @Description: Rundeck基础API操作 
'''

import requests
import json
import sys

class RequestFailed(Exception):
	""" 请求失败异常 """
	def __init__(self,message):
		self.message = message

	def __str__(self):
		return str(self.message)


class Rundeck():
	""" Rundeck基础类 """
	def __init__(self):
		self.baseUrl = 'http://test.deployment.jidongnet.com:4440'
		self.apiToken = 'UtkXpwVH3fZH8ew7MDSEA7mow2jLd2JJ'
		self.headers = {
						'Accept' : 'application/json',
						'X-Rundeck-Auth-Token' : self.apiToken
						}

	def _getApi(self,uri,method='get',data={}):
		self.initApi = self.baseUrl + uri
		if 'get' == method:
			r = requests.get(self.initApi,headers=self.headers)
		elif 'post' == method:
			self.headers['Content-Type'] = 'application/json'
			r = requests.post(self.initApi,data=data,headers=self.headers)


		# print self.headers
		# print r.status_code
		# print self.initApi
		# print r.headers
		# print r.text
		if r.status_code != 200 :
			print json.dumps(json.loads(r.text),indent=2,ensure_ascii=False)
			raise RequestFailed(u"接口请求失败. \n")
		else:
			if r.headers['content-type'] == 'application/json;charset=UTF-8':
				return json.loads(r.text)
			elif 'attachment' in r.headers['content-disposition']:
				filename = r.headers["content-disposition"].split("=")[-1].strip('"')
				file(filename,'wb').write(r.content)
				return filename
			else:
				raise RequestFailed(u"返回类型处理错误")

	def getPrjectsAll(self):
		''' 获取所有项目 '''
		uri =  '/api/1/projects' 
		return self._getApi(uri)

	def createProject(self,project):
		''' 创建项目 '''
		uri = '/api/11/projects'
		data = {
				'name':	project,
				"config": { "propname":"propvalue" }
				}
		return self._getApi(uri, method='post', data=data)

	def exportProject(self,project):
		'''  项目导出 '''
		uri = '/api/11/project/%s/export' % project
		return self._getApi(uri)

	def importProject(self,project):
		''' 项目导入 '''
		uri = '/api/14/project/%s/import{?jobUuidOption,importExecutions,importConfig,importACL}' % project
		requests.put('',headers=headers)


if __name__ == '__main__':
	rundeck = Rundeck()
	a = rundeck.getPrjectsAll()
	print json.dumps(a,indent=2,ensure_ascii=False)
	# print rundeck.exportProject('Immortal_Iosyyace')
	a = rundeck.createProject('xiaodong_test')
	print json.dumps(a,indent=2,ensure_ascii=False)



		