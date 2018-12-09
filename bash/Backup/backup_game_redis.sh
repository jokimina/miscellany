#/bin/bash
# 加勒比redis备份脚本
# 0 5,22 * * * /bin/bash /data/tools/backup_game_redis.sh  &> /dev/null


game_redis_ports=$(ps -ef|egrep 'redis-server6[58]'|awk '{print $NF}'|awk -F":" '{print $2}')
backup_dir=/backup/redis

current_date=$(date +%Y%m%d%H)
mkdir -p $backup_dir/$current_date

for port in $(echo $game_redis_ports)
do 
#backup aof file

    cp -pv  /var/lib/redis/appendonly${port}*     $backup_dir/$current_date/

#do redis snapshot , save data as rdb file
#************  must be very carefully when using redis command *************

    /usr/bin/redis-cli -p $port bgsave

#backup rdb file  

   while [ True ]
   do
       sleep 3 
       progress=$(/usr/bin/redis-cli -p $port info Persistence|grep rdb_bgsave_in_progress|awk -F":" '{print $2}'|awk -F "\r" '{print $1}')

#when bgsave command finish, backup rdb file and exit while loop
       if [ "$progress" == "0" ];then
           echo -e "\e[105mBackup Redis Port $port Data\e[0m"
           cp -pv /var/lib/redis/dump${port}*           $backup_dir/$current_date/
           echo -e "\e[105mBackup Redis Port $port Finished\e[0m"
       else
           echo -e "\e[105mWaiting bgsave command finish\e[0m"
       fi 
       break
   done

done
