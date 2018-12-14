#This script is used to get mongodb server status

#echo "db.serverStatus().uptime"|mongo 192.168.5.23:30002/admin
#echo "db.serverStatus().mem.mapped"|mongo 192.168.5.23:30002/admin
#echo "db.serverStatus().globalLock.activeClients.total"|mongo 192.168.5.23:30002/admin

user="root"
password="1qaz9ol.1qaz9ol."

case $# in
  1)
    output=$(/bin/echo "db.serverStatus().$1" |/data/app_platform/mongodb/bin/mongo 127.0.0.1:28018/admin -u$user -p$password | sed -n '3p')
    ;;
  2)
    output=$(/bin/echo "db.serverStatus().$1.$2" |/data/app_platform/mongodb/bin/mongo 127.0.0.1:28018/admin -u$user -p$password | sed -n '3p')
    ;;
  3)
    output=$(/bin/echo "db.serverStatus().$1.$2.$3" |/data/app_platform/mongodb/bin/mongo 127.0.0.1:28018/admin -u$user -p$password | sed -n '3p')
    ;;
esac

#check if the output contains "NumberLong"
if [[ "$output" =~ "NumberLong"   ]];then
  echo $output|sed -n 's/NumberLong(//p'|sed -n 's/)//p'
else 
  echo $output
fi
