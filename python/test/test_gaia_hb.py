#!/usr/local/bin/python
#  coding: utf-8

import requests
import eventlet
eventlet.monkey_patch()
# eventlet.monkey_patch(thread=False)

from time import time

params = {}
params["userId"] = "2396507"
params["phone"] = '15880249391'
params["cutoffTime"] = "2016-08-07 22:22:22"
params["mtk"] = "c37aa25824cd43d7021d81a0e730b3cf"

def read_url(i):
    result = requests.get(
        # url="http://vpc-gaia.c5d4feda4e91d4bff9802b0abc92e9b83.cn-beijing.alicontainer.com:8989/getUserPhoneSmsRecords",
        url="http://vpc-gaia.c5d4feda4e91d4bff9802b0abc92e9b83.cn-beijing.alicontainer.com:8080/getUserPhoneSmsRecords",
        headers={
            'Host': "vpc-gaia.c5d4feda4e91d4bff9802b0abc92e9b83.cn-beijing.alicontainer.com",
            #'Connection': 'Keep-Alive'
            'Connection': 'close'
        },
        params=params,
        timeout=(10, 5)
    )
    # print result.json()
    print "{}: readed".format(i)
    print result.status_code
    print
    # print result.json()
    print '--'*10


if __name__ == '__main__':

    pool = eventlet.greenpool.GreenPool(1000)

    t1 = time()

    for i in xrange(10):
        pool.spawn(read_url, i)
        print "run %s" % i

    pool.waitall()

    t2 = time()

    print "total time consumed: {}".format(t2-t1)
