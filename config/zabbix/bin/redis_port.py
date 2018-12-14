#/usr/bin/python
#This script is used to discovery redis port on the server
import subprocess
import json
args="netstat -tanp|awk -F':' '/redis-server/&&/LISTEN/{print $2}'|awk '{print $1}'"
t=subprocess.Popen(args,shell=True,stdout=subprocess.PIPE).communicate()[0]
ports=[]

for port in t.split('\n'):
    if len(port) != 0:
       ports.append({'{#REDISPORT}':port})
print json.dumps({'data':ports},indent=4,separators=(',',':'))


