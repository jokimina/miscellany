#!/bin/bash
user=sengoku
hostfile=/data/tools/gamecode_rsync/xinchang/serverlist.txt
sourcefile=/data/zhanguo_demo_gamecode/xinchang/config/merge.conf.php
num=$(cat $hostfile |wc -l)
for i in $(seq 1 $num)
do
    for line in "$(awk "NR==$i" $hostfile)"
    do 
             host=$( echo $line|awk '{print $1}')
             dest=$( echo $line|awk '{print $2}')
             rootdir=$( echo $line|awk '{print $3}')
             cronfile=$rootdir/include/initerioruser.php
#rsync a single file             
#             rsync -avz $sourcefile $user@$host:$rootdir/config/merge.conf.php
#excute php script             
#             ssh $user@$host "php $cronfile"
#             ssh $user@$host -t "sudo  su -c 'grep -oE \"^mysql|^zabbixagent\" /etc/passwd | xargs -n1 -i -t usermod -s /sbin/nologin {} '"
#maintenance              
#              ssh $user@$host "sed -i '/maintenance/s/1/0/'  $rootdir/config/app.conf.php" 
#modify config file
#              ssh $user@$host "sed -i /redis_list/a\"'bi_redis' => array( \n\t 'host' => '192.168.5.23',\n\t 'port' => 6403,\n\t 'db' => 1\n\t),\" $rootdir/config/app.conf.php;php -l $rootdir/config/app.conf.php"
#gzip logs
#              ssh -t $user@$host "nohup sudo find /data/app_data/zhanguo/ -name "*.log" -exec gzip -f  {} \;"
# change encrypt code
#             ssh $user@$host "sed -i  -e '/version/s/1.9.0/2.0.0/'  -e '/hot_update_url/s/ky1.9.0/ky2.0.0/' $rootdir/config/app.conf.php" 
#             ssh $user@$host "rsync -avz /tmp/repiar_everyday_activity_*  192.168.5.156::download"
             echo "$dest"
    done
done

