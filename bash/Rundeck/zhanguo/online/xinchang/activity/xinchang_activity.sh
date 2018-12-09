#!/bin/bash
user=sengoku
hostfile=/data/tools/gamecode_rsync/xinchang/serverlist.txt

activityfile1=/data/zhanguo_demo_gamecode/kaiying/data/tools_release_events.php
#activityfile2=/data/zhanguo_demo_gamecode/kaiying/data/tools_release_*.php

host_base=$(awk '{print $1}' $hostfile|sort|uniq)


echo "$(basename $activityfile1)::::$(md5sum $activityfile1|awk '{print $1}')::::$(date +"%Y-%m-%d %H:%M:%S")"



num=$(cat $hostfile |wc -l)
for i in $(seq 1 $num)
do
    for line in "$(awk "NR==$i" $hostfile)"
    do 
             host=$( echo $line|awk '{print $1}')
             dest=$( echo $line|awk '{print $2}')
             rootdir=$( echo $line|awk '{print $3}')
             rsync -avz  $activityfile1 $activityfile2 $host::$dest/data/
             echo "$dest"
    done
done


##
#reload php-fpm       
for host1 in $host_base
do
            ssh -t $user@$host1 "sudo service php-fpm reload"
done
