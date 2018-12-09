#!/bin/sh
#cron:每天凌晨2点运行一次
#0 2 * * * /bin/bash /data/backup/backup_mongodb.sh &> /var/log/backup_mongodb.log

hosts=( "192.168.5.23:30002" "192.168.5.23:30003" )
#user="backup"
#password="jidongnet.backup"
file=/data/backup/mongodb.txt
# 备份主目录
backup_mongodb_dir="/data/backup/mongodb"
current_date=$(date  +%Y%m%d)
# 备份文件保留天数
last_date=7

if [ ! -d "${backup_mongodb_dir}" ]; then
        mkdir -p ${backup_mongodb_dir}
fi
for _host in ${hosts[@]}
do
    host=$(echo $_host|awk -F: '{print $1}')
    port=$(echo $_host|awk -F: '{print $2}')
	#生成备份数据库列表
	if [ -z $user -o -z $password ];then
	    echo "show dbs"| /data/app_platform/mongodb/bin/mongo admin --host $host --port $port | awk 'BEGIN{OFS=":"}NR>2 && $0 !~ /^bye/{$2=$1":'$port':'$host'";print $0 > "'$file'"}' 
	else
	    echo "show dbs"| /data/app_platform/mongodb/bin/mongo admin --host $host --port $port  -u$user -p$password | awk 'BEGIN{OFS=":"}NR>2 && $0 !~ /^bye/{$2=$1":'$port':'$host'";print $0 > "'$file'"}' 
	fi
	num=$(cat $file |wc -l)
	echo   -e "\e[103mThere are $num  lines in $file \e[0m"
	for i in  $(seq 1  $num)
	do
	        echo "Reading  line $i"
	    for line in "$(awk "NR==$i" $file)"
	        do
	              platform=$( echo $line|awk -F":" '{print $1}') 
	              database=$( echo $line|awk -F":" '{print $2}')
	              port=$( echo $line|awk -F":" '{print $3}')
                  host=$(echo $line| awk -F":" '{print $4}')
	                 
	              if [ -z $user -o -z $password ];then
	                  /data/app_platform/mongodb/bin/mongodump --host $host --port $port  --db $database   -o  ${backup_mongodb_dir}/${platform}_mongodb${current_date}
	              else
	                  /data/app_platform/mongodb/bin/mongodump --authenticationDatabase admin  --host $host --port $port -u$user -p$password   --db $database   -o  ${backup_mongodb_dir}/${platform}_mongodb${current_date}
	              fi
	                   tar   -zcvf ${backup_mongodb_dir}/${platform}_mongodb${current_date}.tar.gz  ${backup_mongodb_dir}/${platform}_mongodb${current_date}/  --remove-files 
                  # 清理指定天数前的checksum和备份文件.
                  find  ${backup_mongodb_dir} -type f -name "*.tar.gz" -name "checksum*.txt" -ctime ${last_date} -exec rm -fv {} \;
	         done
	done
done

#生成MD5校验文件
cd ${backup_mongodb_dir}
ls *${current_date}* | xargs -n1 -i md5sum {} >> ${backup_mongodb_dir}/checksum${current_date}.txt
