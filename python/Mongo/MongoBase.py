#!/user/bin python
# -*- coding:utf-8 -*-
'''
 @Author:      xiaodong
 @Email:       fuxd@jidongnet.com
 @DateTime:    2015-12-15 14:35:19
 @Description: Mongo基类
'''

from pymongo import MongoClient
import pymongo

class operationFailed(Exception):
	""" 操作失败异常 """
	def __init__(self,message):
		self.message = message

	def __str__(self):
		return str(self.message)

class MongoBase(object):
	""" MongoBase Class Libary """

	def __init__(self, host='127.0.0.1',port='27017',db='admin',username=None,password=None):
		"""
			初始化连接,默认连接admin库,获取权限后,select切换目标DB.
		"""
		self.host = host
		self.port = port
		self.db = db
		self.username = username
		self.password = password
		if not username and not password:
			uri = 'mongodb://%s:%s/%s' % (self.host,self.port,self.db)
		else:
			uri = 'mongodb://%s:%s@%s:%s/admin' % (self.username,self.password,self.host,self.port)
		self.conn = MongoClient(uri)
		self._db = self.conn.get_database(self.db)

	def __del__(self):
		self.conn.close()


	def selectDatabase(self,db=None):
		"""
		 : 选取DB
		"""
		if not db:
			raise operationFailed(u'请选择db!')
		self.db = db
		self._db = self.conn.get_database(db)
		return self._db

	def selectCollection(self,collection=None):
		"""
		 : 选取集合(表)
		"""
		if not collection:
			raise operationFailed(u'请选择collection!')
		self._collection = self._db.get_collection(collection)
		return self._collection

	def getAllDatebaseName(self):
		"""
          : 读取所有DB名称,如果mongo版本为2.6以上,并且开启认证状态,需要则需要在admin库下获取正确授权
		"""
		return self.conn.database_names()

	def getAllCollectionName(self,db=None,exclude_system=True):
		"""
         : 读取所有collection名称
		 ：exclude_system 默认不包括系统的集合
		"""
		if not db:
			collections =  self._db.collection_names()
		else:
			collections = self.selectDatabase(db).collection_names()
		if exclude_system:
			collections = filter(lambda c: not c.startswith('system'),collections)
		return  collections

	def createIndex(self,dbs,config):
		""" 根据指定配置生成索引.
		: background 默认False 在后台建立索引 避免阻塞数据库
		: dbs  需要建立索引的数据库
		  login 登陆服   game 游戏服
		  {
			'login': ['zhanguo2_passport'],
			'game':  ['zhanguo2_dev_s1','zhanguo2_dev_s2']
			}
		：config 索引配置文件 一般不需要改动
		  {
			'login': [
				{"collectionName":"account","index":{"accountId":1}},
				{"collectionName":"cdkey","index":{"uid":1}},
				{"collectionName":"pay","index":{"uid":1}}
			 ],
			'game': [
				{"collectionName":"activity","index":{"uid":1}},
				{"collectionName":"avatar","index":{"uid":1},"unique":True},
				{"collectionName":"backpack","index":{"uid":1},"unique":True},
				{"collectionName":"collection","index":{"uid":1},"unique":True},
				{"collectionName":"colourEgg","index":{"uid":1},"unique":True}
			]
		   }
		"""

		if not isinstance(dbs,dict) or not isinstance(config,dict):
			raise operationFailed('\n config error !!! \n'+self.createIndex.__doc__)




		# 遍历数据库类型 game or login
		for t in dbs:
			# 遍历每个类型中的每个DB
			for db in dbs[t]:
				# 定义空集合错误列表
				nullList = []
				self.selectDatabase(db)
				collections = self.getAllCollectionName()
				# 获取对应类型的index配置
				index_collection = config['game'] if t == 'game' else config['login']
				# 判断是否有不存在的集合
				for c in index_collection:
					if c['collectionName'] not in collections:
						nullList.append(c['collectionName'])
				else:
					if nullList:
						raise operationFailed('database [%s] collections [%s] not exist !! please check you config ' % (db ,','.join(nullList)))

				for collection in index_collection:
					self.selectCollection(collection['collectionName'])
					index =  [ i for i in collection['index'].iteritems() ]
					if collection.has_key('unique'):
						self._collection.create_index(index,unique=True,name=collection['collectionName'])
					else:
						self._collection.create_index(index,name=collection['collectionName'])
				else:
					print 'database [ %s ] create index done..' % self._db.name


	def add_user(self,username,password,read_only=None):
		""" 添加用户 """
		self._db.add_user('test','test',read_only=read_only)



if __name__ == '__main__':
	host = '10.10.41.28'
	port = '28018'
	username = ''
	password = ''
	client = MongoBase(host=host,port=port)
	databases = client.getAllDatebaseName()
	user = 'test'
	pwd  = 'test'
	try:
		for db in databases:
			client.selectDatabase(db)
			client.add_user(user, pwd)
			print ' add user %s done on database [ %s ] ' % (user,client.db)
	except Exception, e:
		print e
