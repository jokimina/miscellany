#!/bin/bash
user=sengoku
hostfile=/data/tools/gamecode_rsync/kaiying/serverlist.txt
sourcefile=/data/zhanguo_demo_gamecode/kaiying/cron/country_bonus_tmp.php
num=$(cat $hostfile |wc -l)
for i in $(seq 1 $num)
do
    for line in "$(awk "NR==$i" $hostfile)"
    do 
             host=$( echo $line|awk '{print $1}')
             dest=$( echo $line|awk '{print $2}')
             rootdir=$( echo $line|awk '{print $3}')
             cronfile=$rootdir/cron/country_bonus_tmp.php
#rsync a single file             
             #rsync -avz $sourcefile $user@$host:$rootdir/cron/country_bonus_tmp.php
#excute php script            # 
             #ssh $user@$host "php   $cronfile" 
#             ssh $user@$host -t "sudo  su -c 'grep -oE \"^mysql|^zabbixagent\" /etc/passwd | xargs -n1 -i -t usermod -s /sbin/nologin {} '"
            
#             ssh $user@$host "rsync -avz /tmp/pay_*.txt  192.168.5.156::download"
#maintenance              

#        ssh $user@$host "sed -i '/maintenance/s/1/0/'  $rootdir/config/app.conf.php" 

#              ssh $user@$host "sed -i  's/biqa-log.break-media.com.cn/bi-log.youxi021.com/'  $rootdir/config/app.conf.php" 
#modify config files
#         ssh $user@$host "sed -i /redis_list/a\"'bi_redis' => array( \n\t 'host' => '192.168.5.23',\n\t 'port' =>   6403,\n\t 'db' => 1\n\t),\" $rootdir/config/app.conf.php;php -l $rootdir/config/app.conf.php"

#
#OK="No syntax errors detected in $rootdir/config/app.conf.php"

#echo "$dest start !!!!!!!"
#ssh $user@$host "rsync -avz $rootdir/config/app.conf.php $rootdir/config/app.conf.php20150206;
#sed  -i \"/db_list/i\    'mongo_list' => array(  \n\
#        'country' => array( \n\
#            'server' => 'mongodb://192.168.5.23:30002', \n\
#            'option' => array(  \n\
#                'db' => 'kaiying_zhanguo_country', \n\
#                'username' => 'zhanguo', \n\
#                'password' => 'Break{zhanguo,game}2013', \n\
#                                ), \n\
#        ), \n\
#    ),\" $rootdir/config/app.conf.php;
#        "
##ssh $user@$host "rsync -avz $rootdir/config/app.conf.php.bak $rootdir/config/app.conf.php;php -l $rootdir/config/app.conf.php"

#gzip logs
#              ssh -t $user@$host "nohup sudo find /data/app_data/zhanguo/ -name "*.log" -exec gzip -f  {} \;"
# change encrypt code
         #      ssh $user@$host "cp $rootdir/config/app.conf.php $rootdir/config/app.conf.php20150205;sed -i  -e '/version/s/2.0.0/2.1.0/'  -e '/hot_update_url/s/ky2.0.0/ky2.1.3/' $rootdir/config/app.conf.php" 
               #ssh $user@$host "cp $rootdir/config/app.conf.php $rootdir/config/app.conf.php20150205;sed -i  -e '/version/s/2.0.0/2.1.0/'  -e '/hot_update_url/s/457/458/' $rootdir/config/app.conf.php" 
             echo "$dest end !!!!!!!"
    done
done

