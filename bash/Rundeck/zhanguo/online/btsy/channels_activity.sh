#!/bin/bash
user=sengoku
hostfile=/data/tools/gamecode_rsync/channels/serverlist.txt
activityfile=/data/zhanguo_demo_gamecode/360/data/events.php
num=$(cat $hostfile |wc -l)
for i in $(seq 1 $num)
do
    for line in "$(awk "NR==$i" $hostfile)"
    do 
             host=$( echo $line|awk '{print $1}')
             dest=$( echo $line|awk '{print $2}')
             rootdir=$( echo $line|awk '{print $3}')
             rsync -avz  $activityfile $host::$dest/data/
             ssh -t $user@$host "sudo service php-fpm reload"
             echo "$dest"
    done
done

