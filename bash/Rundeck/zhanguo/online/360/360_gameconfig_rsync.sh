#!/bin/bash
user=sengoku
platform=360
version=1.7.0
num=$(cat serverlist.txt |wc -l)
hot_version_file=/data/zhanguo_demo_gamecode/360/hot_version.txt
gmconfig=/var/www/html/zhanguo-backend-360/protected/apps/zg/config/api.yml
for i in $(seq 1 $num)
do  
         for line in "$(awk "NR==$i" serverlist.txt)"
         do
             host=$( echo $line|awk '{print $1}')
             coderoot=$( echo $line|awk '{print $3}')
             config=$coderoot/config/app.conf.php
             hot_version_old=$(ssh $user@$host "grep hot_version  $config"|awk '{print $3}'|awk -F"," '{print $1}')
             echo -e "\e[033mThe old hot version is $hot_version_old\e[0m"
             hot_version_update=$(awk -F":" '/hot_version/{print $2}' $hot_version_file)
             echo -e "\e[033mThe new hot version will be $hot_version_update\e[0m"
             ssh $user@$host "sed  -i   -e "/hot_version/s/$hot_version_old/$hot_version_update/"  -e  "/hot_update_url/s/$version.$hot_version_old/$version.$hot_version_update/"  $config"

             hot_version=$( ssh  $user@$host  "awk '/hot_version/{print \$3}' $config|awk -F',' '{print \$1}'")
             echo -e "\e[033mNow the  hot version is $hot_version\e[0m"

             echo "$host ::::: $config"
    done
done
             echo -e "\e[034mChanging GM Backend Version\e[0m"
             gmversion=$(ssh   wangdeyuan@101.231.68.46 "grep -A2 production $gmconfig|awk -F":" '/hotver/{print \$2}'")
             echo "$gmversion"
             echo -e "\e[034mThe Current GM Backend Version is $gmversion\e[0m"
             gmversion_new=${hot_version_update}
             echo -e "\e[034mThe New GM Backend Version Will be Changed to $gmversion_new\e[0m"
             ssh -t  wangdeyuan@101.231.68.46  "sudo sed  -i  "/production/,+2s/hotver:$gmversion/hotver:$gmversion_new/"  $gmconfig"
