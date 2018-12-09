#!/usr/bin/python2
import sys
import os
import redis
import time
import datetime

string_keys=[]
hash_keys=[]
list_keys=[]
set_keys=[]
zset_keys=[]
def import_string(source, dest):
    print "Begin Import String Type"
    keys_count = len(string_keys)
    print "String Key Count is:",keys_count
    pipeSrc = source.pipeline(transaction=False)
    pipeDst = dest.pipeline(transaction=False)
    index=0
    pipe_size=1000
    while index < keys_count:
        old_index=index
        num=0
        while (index < keys_count) and (num < pipe_size):
            pipeSrc.get(string_keys[index])
            index +=1
            num +=1
        results=pipeSrc.execute()
        for value in results:
            pipeDst.set(string_keys[old_index], value)
            old_index +=1
        pipeDst.execute()
def import_hash(source, dest):
    print "Begin Import Hash Type"
    keys_count = len(hash_keys)
    print "Hash Key Count is:",keys_count
    pipeSrc = source.pipeline(transaction=False)
    pipeDst = dest.pipeline(transaction=False)
    for key in hash_keys:
        hkeys=source.hkeys(key)
        keys_count = len(hkeys)
        index=0
        pipe_size=1000
        while index < keys_count:
            old_index=index
            num=0
            while (index < keys_count) and (num < pipe_size):
                pipeSrc.hget(key, hkeys[index])
                index +=1
                num +=1
            results=pipeSrc.execute()
            for value in results:
                pipeDst.hset(key, hkeys[old_index], value)
                old_index +=1
            pipeDst.execute()
def import_set(source, dest):
    print "Begin Import Set Type"
    keys_count = len(set_keys)
    print "Set Key Count is:",keys_count
    pipeDst = dest.pipeline(transaction=False)
    for key in set_keys:
        sValues=source.smembers(key)
        value_count = len(sValues)
        index=0
        pipe_size=1000
        while index < value_count:
            old_index=index
            num=0
            while (index < value_count) and (num < pipe_size):
                pipeDst.sadd(key, sValues.pop())
                index +=1
                num +=1
            pipeDst.execute()

def import_zset(source, dest):
    print "Begin Import ZSet Type"
    keys_count = len(zset_keys)
    print "ZSet Key Count is:",keys_count
    pipeSrc = source.pipeline(transaction=False)
    pipeDst = dest.pipeline(transaction=False)
    for key in zset_keys:
        zset_size = source.zcard(key)
        index=0
        pipe_size=1000
        while index < zset_size:
            members = source.zrange(key, index, index+pipe_size)
            index += len(members)
            for member in members:
                pipeSrc.zscore(key, member)
            scores = pipeSrc.execute()
            i=0
            for member in members:
                pipeDst.zadd(key, member, scores[i])
                i+=1
            pipeDst.execute()

def import_list(source, dest):
    print "Begin Import List Type"
    keys_count = len(list_keys)
    print "List Key Count is:",keys_count
    pipeDst = dest.pipeline(transaction=False)
    for key in list_keys:
        list_size = source.llen(key)
        index=0
        pipe_size=1000
        while index < list_size:
            results = source.lrange(key, index, index+pipe_size)
            index += len(results)
            for value in results:
                pipeDst.rpush(key, value)
            pipeDst.execute()

def read_type_keys(source):
    keys=source.keys()
    keys_count = len(keys)
    print "Key Count is:",keys_count
    pipe = source.pipeline(transaction=False)
    #for key in keys:
    index=0
    pipe_size=5000
    while index < keys_count:
        old_index=index
        num=0
        while (index < keys_count) and (num < pipe_size):
            pipe.type(keys[index])
            index +=1
            num +=1
        results=pipe.execute()
        for type in results:
            if type == "string":
                string_keys.append(keys[old_index])
            elif type == "list":
                list_keys.append(keys[old_index])
            elif type == "hash":
                hash_keys.append(keys[old_index])
            elif type == "set":
                set_keys.append(keys[old_index])
            elif type == "zset":
                zset_keys.append(keys[old_index])
            else :
                print keys[old_index]," is not find when TYPE"
            old_index +=1

if __name__=='__main__':
    argc = len(sys.argv)
    if argc != 5:
        print "usage: %s sourceIP sourcePort destIP destPort" % (sys.argv[0])
        exit(1)
    SrcIP = sys.argv[1]
    SrcPort = int(sys.argv[2])
    DstIP = sys.argv[3]
    DstPort = int(sys.argv[4])

    start=datetime.datetime.now()
    source=redis.Redis(host=SrcIP,port=SrcPort)
    dest=redis.Redis(host=DstIP,port=DstPort)

    print "Begin Read Keys"
    read_type_keys(source)
    print "String Key Count is:",len(string_keys)
    print "Set Key Count is:",len(set_keys)
    print "ZSet Key Count is:",len(zset_keys)
    print "List Key Count is:",len(list_keys)
    print "Hash Key Count is:",len(hash_keys)

    import_string(source, dest)
    import_hash(source, dest)
    import_list(source, dest)
    import_set(source, dest)
    import_zset(source, dest)

    stop=datetime.datetime.now()
    diff=stop-start
    print "Finish, token time:",str(diff)
