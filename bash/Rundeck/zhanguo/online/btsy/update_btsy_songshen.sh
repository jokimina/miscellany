#!/bin/bash
#update jidong apple songshen login and game code
ssh -t  wangdeyuan@101.231.68.46 "ssh sengoku@10.10.41.42 'cd /data/tools/updatecode/apple/;sh update_jidong_apple_songshen_logincode.sh;sh update_jidong_apple_songshen_gamecode.sh'"



dir_base=/data/zhanguo_app/apple/zhanguo_server
dir_config_file=$dir_base/config/app.conf.php
dir_resource_file=$dir_base/htdoc/resource/hot_update_file.json
hot_version_old=$(awk '/hot_version/{print $3}' $dir_config_file|awk -F "," '{print $1}') 
hot_version_update=$(awk -F"," '{print $1}' $dir_resource_file|awk -F ":" '{print $2}')

echo -e "\nThe old hot version is $hot_version_old\n"
echo -e "\nThe update hot version is $hot_version_update\n"
echo -e "\nNow the hot version will be updated from $hot_version_old to $hot_version_update\n"
sed -i "/hot_version/s/$hot_version_old/$hot_version_update/" $dir_config_file

hot_version_new=$(awk '/hot_version/{print $3}' $dir_config_file|awk -F "," '{print $1}') 
echo -e "\nNow the hot version is $hot_version_new\n"

awk '/hot_version/{print}' $dir_config_file|mail -s "Updating Jidong Platform Songshen Code  On $(date +%Y/%m/%d/%H/%M)  Operated by $USER"  wangdy@jidonggame.com  wangws@jidonggame.com xugl@jidonggame.com
