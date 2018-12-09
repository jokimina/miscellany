#!/bin/bash
user=sengoku
num=$(cat serverlist.txt |wc -l)
hot_version_file=/data/zhanguo_demo_gamecode/renren/hot_version.txt
for i in $(seq 1 $num)
do
    for line in "$(awk "NR==$i" serverlist.txt)"
    do 
             host=$( echo $line|awk '{print $1}')
             coderoot=$( echo $line|awk '{print $3}')
             config=$coderoot/config/app.conf.php
             hot_version_old=$(ssh $user@$host "grep hot_version  $config"|awk '{print $3}'|awk -F"," '{print $1}')
             echo -e "\e[033mThe old hot version is $hot_version_old\e[0m"
             hot_version_update=$(awk -F":" '{print $2}' $hot_version_file)
             echo -e "\e[033mThe new hot version will be $hot_version_update\e[0m"
             ssh $user@$host "sed  -i   -e "/hot_version/s/$hot_version_old/$hot_version_update/"  -e  "/hot_update_url/s/1.6.0.$hot_version_old/1.6.0.$hot_version_update/"  $config"
     
             hot_version=$( ssh  $user@$host  "awk '/hot_version/{print \$3}' $config|awk -F',' '{print \$1}'")
             echo -e "\e[033mNow the  hot version is $hot_version\e[0m"






#             ssh $user@$host  "sed  -i  -e '/version/s/1.6.0/1.6.1/'     -e '/hot_version/s/6/7/' -e  '/hot_update_url/s/1.6.1.6/1.6.1.7/' $config" 
#             ssh $user@$host  "sed  -i  '/maintenance/s/1/0/' $config"
             echo "$host ::::: $config"
    done
done

