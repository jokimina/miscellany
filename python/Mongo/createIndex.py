#!/user/bin python
# -*- coding:utf-8 -*- 
'''
 @Author:      xiaodong
 @Email:       fuxd@jidongnet.com
 @DateTime:    2015-12-16 20:00:09
 @Description: mongo建立索引 
'''
from MongoBase import MongoBase
from MongoBase import operationFailed


class indexModule(MongoBase):
	def __init__(self, host='127.0.0.1',port='27017',db='admin',username=None,password=None):
		super(indexModule, self).__init__(host=host,port=port,db=db,username=username,password=password)
				
		
	def createIndex(self,dbs,config):
			""" 根据指定配置生成索引. 
			: background 默认False 在后台建立索引 避免阻塞数据库
			: dbs  需要建立索引的数据库
			  login 登陆服   game 游戏服
			  { 
				'login': ['zhanguo2_passport'],
				'game':  ['zhanguo2_dev_s1','zhanguo2_dev_s2']
				}
			: config 索引配置文件 一般不需要改动
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

if __name__ == '__main__':

	dbs =  { 
			'login': ['jidong_immortal_passport','iosyy_immortal_passport'],
			'game':  ['jidong_immortal_game1','iosyy_immortal_game1','iosyy_immortal_game2','iosyy_immortal_game10000']
		}

	index_config = {
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
			{"collectionName":"colourEgg","index":{"uid":1},"unique":True},
			{"collectionName":"function","index":{"uid":1},"unique":True},
			{"collectionName":"guide","index":{"uid":1},"unique":True},
			{"collectionName":"inbox","index":{"uid":1}},
			{"collectionName":"logCount","index":{"uid":1},"unique":True},
			{"collectionName":"logPvp","index":{"uid":1}},
			{"collectionName":"logSource","index":{"uid":1}},
			{"collectionName":"mission","index":{"uid":1},"unique":True},
			{"collectionName":"nickname","index":{"uid":1}},
			{"collectionName":"payCard","index":{"uid":1}},
			{"collectionName":"player","index":{"uid":1},"unique":True},
			{"collectionName":"pvp","index":{"ranking":1}},
			{"collectionName":"reward","index":{"uid":1},"unique":True},
			{"collectionName":"samurai","index":{"uid":1},"unique":True},
			{"collectionName":"samuraiEquip","index":{"uid":1},"unique":True},
			{"collectionName":"signIn","index":{"uid":1},"unique":True},
			{"collectionName":"skill","index":{"uid":1},"unique":True},
			{"collectionName":"stage","index":{"uid":1},"unique":True},
			{"collectionName":"stageActivity","index":{"uid":1},"unique":True},
			{"collectionName":"summon","index":{"uid":1},"unique":True},
			{"collectionName":"vipgift","index":{"uid":1}}
		]
	}

	host = '10.10.41.28'
	port = '28018'
	username = ''
	password = ''

	client = indexModule(host=host,port=port)
	try:
		client.createIndex(dbs=dbs,config=index_config)
	except TypeError, e:
		print e
		print help(MongoBase.createIndex)