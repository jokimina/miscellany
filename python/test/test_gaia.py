import requests
import requests.adapters
import eventlet
import traceback
import argparse
eventlet.monkey_patch()
pool = eventlet.greenpool.GreenPool(1000)
s = requests.Session()
a = requests.adapters.HTTPAdapter(pool_connections=50, pool_maxsize=100, pool_block=True, max_retries=0)
s.mount('http://', a)
url="http://vpc-gaia.c5d4feda4e91d4bff9802b0abc92e9b83.cn-beijing.alicontainer.com/getUserPhoneSmsRecords?phone=15880249391&userId=2396507&cutoffTime=2016-08-07+17%3A11%3A07&mtk=c37aa25824cd43d7021d81a0e730b3cf"

def read_url_withpool(url):
    global s
    try:
        print "requests sended"
        req2 = s.get(url, timeout=(10, 30))
        print "readed"
    except:
        print traceback.format_exc()

def read_url(url):
    try:
        print "requests sended"
        req2 = requests.get(url, timeout=(10, 30))
        print "readed"
    except:
        print traceback.format_exc()

def main():
    funcs = {
        'read_url_withpool': read_url_withpool,
        'read_url': read_url,
    }
    parser = argparse.ArgumentParser(description='generate running scripts')
    parser.add_argument('command', choices=funcs.keys())
    parser.add_argument('--runsize', help='input file', default=100)
    args = parser.parse_args()

    for i in xrange(int(args.runsize)):
        pool.spawn(funcs[args.command], (url))
        print "run %s" % i

    pool.waitall()
if __name__ == '__main__':
    main()