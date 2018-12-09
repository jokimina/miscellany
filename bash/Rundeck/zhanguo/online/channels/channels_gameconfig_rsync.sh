#!/bin/bash
user=sengoku
platform=360
version=1.7.0
serverlist=/data/tools/gamecode_rsync/channels/serverlist.txt
num=$(cat $serverlist |wc -l)
hot_version_file=/data/zhanguo_demo_gamecode/360/hot_version.txt
gmconfig360=/var/www/html/zhanguo-backend-360/protected/apps/zg/config/api.yml
gmconfiguc=/var/www/html/zhanguo-backend-ucgame/protected/apps/zg/config/api.yml
gmconfigios=/var/www/html/zhanguo-backend-fk/protected/apps/zg/config/api.yml
gmconfigandroid=/var/www/html/zhanguo-backend-fk-apk/protected/apps/zg/config/api.yml
for i in $(seq 1 $num)
do  
         for line in "$(awk "NR==$i" $serverlist)"
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
             echo -e "\e[034mChanging 360  GM Backend Version\e[0m"
             gmversion360=$(ssh   wangdeyuan@101.231.68.46 "grep -A2 production $gmconfig360|awk -F":" '/hotver/{print \$2}'")
             echo "$gmversion360"
             echo -e "\e[034mThe Current 360  GM Backend Version is $gmversion360\e[0m"
             gmversion360_new=${hot_version_update}
             echo -e "\e[034mThe New GM Backend Version Will be Changed to $gmversion360_new\e[0m"
             ssh -t  wangdeyuan@101.231.68.46  "sudo sed  -i  "/production/,+2s/hotver:$gmversion360/hotver:$gmversion360_new/"  $gmconfig360"



             echo -e "\e[034mChanging UC  GM Backend Version\e[0m"
             gmversionuc=$(ssh   wangdeyuan@101.231.68.46 "grep -A2 production $gmconfiguc|awk -F":" '/hotver/{print \$2}'")
             echo "$gmversionuc"
             echo -e "\e[034mThe Current UC  GM Backend Version is $gmversionuc\e[0m"
             gmversionuc_new=${hot_version_update}
             echo -e "\e[034mThe New GM Backend Version Will be Changed to $gmversionuc_new\e[0m"
             ssh -t  wangdeyuan@101.231.68.46  "sudo sed  -i  "/production/,+2s/hotver:$gmversionuc/hotver:$gmversionuc_new/"  $gmconfiguc"





              echo -e "\e[034mChanging GM Backend Version 91 IOS and Android\e[0m"
             gmversionios=$(ssh   wangdeyuan@101.231.68.46 "grep -A2 production $gmconfigios|awk -F":" '/hotver/{print \$2}'")
             gmversionandroid=$(ssh   wangdeyuan@101.231.68.46 "grep -A2 production $gmconfigandroid|awk -F":" '/hotver/{print \$2}'")
             echo "$gmversionios"
             echo "$gmversionandroid"
             echo -e "\e[034mThe Current GM Backend Version is $gmversionios\e[0m" 
             echo -e "\e[034mThe Current GM Backend Version is $gmversionandroid\e[0m" 
             gmversion_new=${hot_version_update}
             echo -e "\e[034mThe New GM Backend Version Will be Changed to $gmversion_new\e[0m" 
              ssh -t  wangdeyuan@101.231.68.46  "sudo sed  -i  "/production/,+2s/hotver:$gmversionios/hotver:$gmversion_new/"  $gmconfigios"
              ssh -t  wangdeyuan@101.231.68.46  "sudo sed  -i  "/production/,+2s/hotver:$gmversionandroid/hotver:$gmversion_new/"  $gmconfigandroid"
