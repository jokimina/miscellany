#!/usr/bin/python2
import sys
import os
import redis
import time
import datetime


def rename_keys(source):
    keys=source.keys()
    keys_count = len(keys)
    print "Key Count is:",keys_count
    print "Begin Rename Keys"
    pipe = source.pipeline(transaction=False)
    #for key in keys:
    index=0
    pipe_size=5000
    while index < keys_count:
        num=0
        while (index < keys_count) and (num < pipe_size):
            if len(keys[index]) > 7 and keys[index][6] == "." :
                pipe.rename(keys[index], keys[index][7:])
            index +=1
            num +=1

        try:
            results=pipe.execute()
        except Exception, exception:
            print exception

if __name__=='__main__':
    argc = len(sys.argv)
    if argc != 3:
        print "usage: %s sourceIP sourcePort" % (sys.argv[0])
        exit(1)
    SrcIP = sys.argv[1]
    SrcPort = int(sys.argv[2])

    start=datetime.datetime.now()
    source=redis.Redis(host=SrcIP,port=SrcPort)

    print "Begin Read Keys"
    rename_keys(source)

    stop=datetime.datetime.now()
    diff=stop-start
    print "Finish, token time:",str(diff)
