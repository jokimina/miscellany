#!/bin/bash
user=sengoku
hostfile=/data/tools/gamecode_rsync/channels_xc/serverlist.txt
#tmp_file=/data/zhanguo_demo_gamecode/channels_xc/include/maintenance.php 
tmp_file=challenge_week_rank_bonus.php
num=$(cat $hostfile |wc -l)
for i in $(seq 1 $num)
do
    for line in "$(awk "NR==$i" $hostfile)"
    do 
             host=$( echo $line|awk '{print $1}')
             dest=$( echo $line|awk '{print $2}')
             rootdir=$( echo $line|awk '{print $3}')
#2013 12 19 
#            ssh $user@$host "php $rootdir/cron/repair_vassal_data.php;php $rootdir/cron/vassal_stats.php;rsync -avz /tmp/vassal_*.csv   10.4.7.169::download" 

             #rsync -avz $tmp_file  $user@$host:$rootdir/include/maintenance.php
#             rsync -avz $tmp_file  $user@$host:$rootdir/cron/

#            ssh $user@$host "php $rootdir/cron/country_bonus.php " 

#             ssh $user@$host "sed -i -e '/app_secret/s/jidongnetjidongnet/jidongnet/' -e '/pack_encrypt_key/s/bReAkgAmE@2012/jieAkgAmE@2012/' -e '/data_encrypt_key/s/brEakgAMe/jiEakgAMe/' -e '/psid_encrypt_key/s/jidongnetjidongnet/jidongnet/'  $rootdir/config/app.conf.php" 
#maintenance operation
             ssh $user@$host "sed -i '/maintenance/s/1/0/' $rootdir/config/app.conf.php" 
#              ssh $user@$host "sed -i -e  '/version/s/1.1.0/1.2.0/'  -e '/hot_update_url/s/1.1.0.287/1.2.0.57/'   $rootdir/config/app.conf.php"               

#add string for all config,must very carefully!!!
#OK="No syntax errors detected in $rootdir/config/app.conf.php"
#ssh $user@$host "rsync -avz $rootdir/config/app.conf.php $rootdir/config/app.conf.php20150206;
#sed  -i \"/db_list/i\    'mongo_list' => array(  \n\
#        'country' => array( \n\
#            'server' => 'mongodb://10.4.8.114:28018', \n\
#            'option' => array(  \n\
#                'db' => 'xinchang_zhanguo_country', \n\
#                'username' => 'zhanguo', \n\
#                'password' => 'Jidong{zhanguo2013}', \n\
#                                ), \n\
#        ), \n\
#    ),\" $rootdir/config/app.conf.php;
#        "
##ssh $user@$host "rsync -avz $rootdir/config/app.conf.php.bak $rootdir/config/app.conf.php;php -l $rootdir/config/app.conf.php"
             echo "$dest"
    done
done

