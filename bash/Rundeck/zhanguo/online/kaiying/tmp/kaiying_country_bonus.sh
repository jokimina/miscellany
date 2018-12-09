#!/bin/bash
user=sengoku
hostfile=/data/tools/gamecode_rsync/kaiying/serverlist.txt
num=$(cat $hostfile |wc -l)
for i in $(seq 1 $num)
do
    for line in "$(awk "NR==$i" $hostfile)"
    do 
             host=$( echo $line|awk '{print $1}')
             dest=$( echo $line|awk '{print $2}')
             rootdir=$( echo $line|awk '{print $3}')
             cronfile=$rootdir/cron/country_bonus.php 
             echo "--------------- $dest start! --------------------"
             #ssh $user@$host "php  -l  $cronfile;ls -l $cronfile" 
             ssh $user@$host "php    $cronfile" 
             echo "-------------- $dest end !!!!!!! ----------------------- "
             echo " "
    done
done

