#!/bin/bash

version=2.0.0

 hot_version_old=$(awk '/hot_version/{print $3}'  /data/zhanguo_demo_gamecode/xinchang/config/app.conf.php|awk -F"," '{print $1}')

rsync -avz   --exclude ".svn" --exclude "htdoc/resource" /data/zhanguo_demo_gamecode/xinchang/     /data/gamecode/xinchang/backup/$version.$hot_version_old

 cd /data/gamecode/xinchang/new/
 rsync    -aP   --exclude "config/app.conf.php*"   --exclude="data/events.php"     --exclude "htdoc/resource/*" --exclude ".svn/"  --exclude "include/maintenance.php"     --exclude "include/initerioruser.php"       hot_version.txt  *  /data/zhanguo_demo_gamecode/xinchang/

 echo -e "\e[033mThe old hot version is $hot_version_old\e[0m"
 hot_version_update=$(awk -F":" '{print $2}' hot_version.txt)
 sed  -i   -e "/hot_version/s/$hot_version_old/$hot_version_update/"  -e  "/hot_update_url/s/ky$version\_$hot_version_old/ky$version\_$hot_version_update/"   /data/zhanguo_demo_gamecode/xinchang/config/app.conf.php
 sudo service php-fpm reload
 hot_version_new=$(awk '/hot_version/{print $3}'  /data/zhanguo_demo_gamecode/xinchang/config/app.conf.php|awk -F"," '{print $1}')
 echo -e "\e[033mThe new hot version is $hot_version_new\e[0m"




gmconfig=/var/www/html/xinchang-backend-kingnet-appstore/protected/apps/zg/config/api.yml

hot_version_update=$(awk -F":" '/hot_version/{print $2}' /data/zhanguo_demo_gamecode/xinchang/hot_version.txt)

echo -e "\e[034mChanging GM Backend Version\e[0m"
gmversion=$(ssh   wangdeyuan@101.231.68.46 "grep -A3 production $gmconfig|awk -F":" '/myriad_hotver/{print \$2}'")
echo "$gmversion"
echo -e "\e[034mThe Current GM Backend Version is $gmversion\e[0m"
gmversion_new=${hot_version_update}
echo -e "\e[034mThe New GM Backend Version Will be Changed to $gmversion_new\e[0m"
ssh -t  wangdeyuan@101.231.68.46  "sudo sed  -i  "/production/,+3s/myriad_hotver:$gmversion/myriad_hotver:$gmversion_new/"  $gmconfig"
