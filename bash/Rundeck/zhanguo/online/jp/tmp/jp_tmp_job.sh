#!/bin/bash
user=sengoku
num=$(cat /data/tools/gamecode_rsync/jp/serverlist.txt |wc -l)
sourcefile=/data/zhanguo_demo_gamecode/jp/data/samurai_drop/slotdorp3.php
#sourcefile=country_bonus.php
for i in $(seq 1 $num)
do
    for line in "$(awk "NR==$i" /data/tools/gamecode_rsync/jp/serverlist.txt)"
    do 
             host=$( echo $line|awk '{print $1}')
             server=$( echo $line|awk '{print $2}')
             coderoot=$( echo $line|awk '{print $3}')
             cronfile=$coderoot/data/samurai_drop/slotdorp3.php
             rsync -avz $sourcefile $user@$host:$cronfile
#             ssh $user@$host "(crontab -l 2>/dev/null;echo '5 23 5 1 *  /usr/bin/php  $cronfile')|crontab -"
#              ssh $user@$host "php $cronfile"
#              ssh $user@$host "sed -i '/maintenance/s/1/0/'  $coderoot/config/app.conf.php"
#              ssh $user@$host "sed -n '1,13p'  $coderoot/config/app.conf.php"
              
#             ssh $user@$host "sed -i  -e '/version/s/1.6.0/1.7.0/'  -e '/hot_update_url/s/1.6.0/1.7.0/' $coderoot/config/app.conf.php" 

#add string for all config,must very carefully!!!
#OK="No syntax errors detected in $coderoot/config/app.conf.php"
#ssh $user@$host "rsync -avz $coderoot/config/app.conf.php $coderoot/config/app.conf.php.bak;
#sed  -i \"/db_list/i\    'mongo_list' => array(  \n\
#        'country' => array( \n\
#            'server' => 'mongodb://172.31.12.73:28018', \n\
#            'option' => array(  \n\
#                'db' => 'jp_zhanguo_country', \n\
#                'username' => 'zhanguo', \n\
#                'password' => 'zhanguo123', \n\
#                                ), \n\ 	  ), \n\    ), \n\
#   \" $coderoot/config/app.conf.php; 
#       php -l $coderoot/config/app.conf.php  
#        "
		
             echo "$host :::::"
             echo "$server :::::"
    done
done
