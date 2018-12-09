#!/bin/bash
platform=xinchang
version=1.3.0
hot_update_file=/data/svn/$platform/$version/game_server/htdoc/resource/hot_update_file.json
QA_GAMECODE_DIR="/data/xinchang_app/channels_new/zhanguo_server/
		/data/xinchang_app/channels_new/zhanguo_server_2/
		/data/xinchang_app/channels_new/zhanguo_server_3/
		/data/xinchang_app/channels_new/zhanguo_server_4/"

for qa_gamecode_dir in $QA_GAMECODE_DIR
do
rsync -avz /data/svn/$platform/$version/game_server/  --exclude ".svn" --exclude "config"  --exclude "data/events.php"      $qa_gamecode_dir

hot_version_old=$(awk '/hot_version/{print $3}' $qa_gamecode_dir/config/app.conf.php|awk -F"," '{print $1}')
echo "The old hot version is $hot_version_old"
hot_version_update=$(awk -F"," '/version/{print $1}' $hot_update_file|awk -F":" '{print $2}')

echo "The update hot version is $hot_version_update"

sed -i "/hot_version/s/$hot_version_old/$hot_version_update/" $qa_gamecode_dir/config/app.conf.php


hot_version_new=$(awk '/hot_version/{print $3}' $qa_gamecode_dir/config/app.conf.php|awk -F"," '{print $1}')
echo "The new hot version is $hot_version_new "
done

gmconfig=/pub_code/new/backend_xc_new_42_1.0.0/protected/apps/zg/config/api.yml
  echo -e "\e[034mChanging GM Backend Version\e[0m"
  gmversion=$(ssh   root@10.10.41.101 "grep -A2 production $gmconfig|awk -F":" '/hotver/{print \$2}'")
  echo "$gmversion"
  echo -e "\e[034mThe Current GM Backend Version is $gmversion\e[0m"
  gmversion_new=${hot_version_new}
  echo -e "\e[034mThe New GM Backend Version Will be Changed to $gmversion_new\e[0m"
  ssh -t  root@10.10.41.101  "sudo sed  -i  "/production/,+2s/hotver:$gmversion/hotver:$gmversion_new/"  $gmconfig"
