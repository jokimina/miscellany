#!/user/bin python
# -*- coding:utf-8 -*-
'''
 @Author:      xiaodong
 @Email:       fuxiaodong@xxxxx.com
 @DateTime:    2018-10-19
 @Description: 清除没用的key
'''
import sys
import redis

def clean_excess(host='xx.redis.rds.aliyuncs.com', port=6379, db=0,
                     password='x', pattern=None):
    _redis = redis.StrictRedis(host=host, port=port, db=db, password=password)
    i = None
    while i != 0:
        if i is None: i = 0
        print('>> scan index', i)
        _scan = _redis.scan(i, match=pattern, count="1000000")
        i, l = _scan
        if l:
            for _i in l:
                print("-- delete key {}".format(_i))
                _redis.delete(_i)
if __name__ == '__main__':
    #clean_excess(pattern="athena.cache.contactlist*")
    #clean_excess(pattern="ip.try.counter.*")
