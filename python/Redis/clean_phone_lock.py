#!/user/bin python
# -*- coding:utf-8 -*-
'''
 @Author:      xiaodong
 @Email:       fuxiaodong@xxxxx.com
 @DateTime:    2016-08-26
 @Description: 清除锁定的手机号缓存
'''
import sys
import redis

def clean_phone_lock(phone_number,host='10.170.254.90',port=6379,db=0,password='xxx'):
    str_key = 'smscode.cnt.{}'.format(phone_number)
    _redis = redis.StrictRedis(host=host,port=port,db=db,password=password)
    str_key_val = _redis.get(str_key)
    if 0 != str_key_val:
        print('-- get key {}: {}'.format(str_key,str_key_val))
        print('-- set key {} to {}'.format(str_key,0))
        _redis.set(str_key,0)
        print('-- now key {}: {}'.format(str_key,_redis.get(str_key)))
    else:
        print('failed,check your phone_number!')
if __name__ == '__main__':
    try:
        phone_number = sys.argv[1]
        if 11 == len(phone_number):
            clean_phone_lock(str(phone_number))
        else:
            print('wrong params!')
    except IndexError as e:
        print('usage: python {} phone_number'.format(__file__))
        print('  e.g: python {} 13671663037'.format(__file__))
