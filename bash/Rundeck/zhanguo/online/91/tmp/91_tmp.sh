#!/bin/bash
user=sengoku
num=$(cat ../serverlist.txt |wc -l)
for i in $(seq 1 $num)
do
    for line in "$(awk "NR==$i" ../serverlist.txt)"
    do 
             host=$( echo $line|awk '{print $1}')
             dest=$( echo $line|awk '{print $2}')
             rootdir=$( echo $line|awk '{print $3}')
             config="$rootdir/config/app.conf.php"
#             ssh $user@$host  "cp $config /tmp/app.conf.php$dest;rsync -avz /tmp/app.conf.php$dest 10.4.7.169::download"
             ssh $user@$host "sed -i -e '/app_secret/s/ZhangGuo{8ik,lp-}@2012#/ZhangGuo{8ik,lp-}@2012#jidongnet/' -e '/pack_encrypt_key/s/bReAkgAmE@2012/jieAkgAmE@2012/' -e '/data_encrypt_key/s/brEakgAMe/jiEakgAMe/' -e '/psid_encrypt_key/s/testtoken/testtokenjidongnet/'  $rootdir/config/app.conf.php" 
#             ssh $user@$host  "sed  -i  '/maintenance/s/0/1/' $config"
             echo "$host :: $rootdir"
    done
done

