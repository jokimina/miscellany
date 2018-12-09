#!/bin/sh
#cron:每天凌晨5点运行一次
#0 5 * * * /bin/bash /data/backup/backup_redis.sh &> /var/log/backup_redis.log
root_redis_dir="/data/app_data/redis"
backup_redis_dir="/data/backup/redis"
current_date=$(date  +%Y%m%d)
last_date=$(date --date '7 days ago' +%Y%m%d)
redis_host="172.31.30.57"

if [ ! -d "${backup_redis_dir}" ]; then
     mkdir -p ${backup_redis_dir}
fi
#打包游戏服上的redis的数据文件和日志文件
ssh gintama@${redis_host} -t "sudo mkdir -p ${backup_redis_dir};sudo rm -fv ${backup_redis_dir}/redis${last_date}.tar.gz;sudo tar --ignore-failed-read -Pzcvf ${backup_redis_dir}/redis${current_date}.tar.gz  ${root_redis_dir}"
#同步到本地目录
rsync -avz ${redis_host}::backup_database/redis/* ${backup_redis_dir}
[ $? -eq 0 ]&&echo "Success to backup redis: ${backup_redis_dir}/game_redis$current_date.tar.gz"

 sudo rm -fv  ${backup_redis_dir}/redis${last_date}.tar.gz


#生成redis MD5校验
cd /data/backup/redis/
ls *${current_date}* | xargs -n1 -i md5sum {} >> /data/backup/redis/checksum${current_date}.txt
