#!/bin/bash
set -x
platform=kingnet
version=2.1.3
hot_update_file=/data/svn/$platform/$version/game_server/htdoc/resource/hot_update_file.json
qa_gamecode_dir=/data/zhanguo_app/kaiying/zhanguo_server/
rsync -avz /data/svn/$platform/$version/game_server/  --exclude ".svn" --exclude "config/app.conf.php*"  --exclude "data/events.php"   $qa_gamecode_dir

hot_version_old=$(awk '/hot_version/{print $3}' $qa_gamecode_dir/config/app.conf.php|awk -F"," '{print $1}')
echo "The old hot version is $hot_version_old"
hot_version_update=$(awk -F"," '/version/{print $1}' $hot_update_file|awk -F":" '{print $2}')

echo "The update hot version is $hot_version_update"

sed -i "/hot_version/s/$hot_version_old/$hot_version_update/" $qa_gamecode_dir/config/app.conf.php


hot_version_new=$(awk '/hot_version/{print $3}' $qa_gamecode_dir/config/app.conf.php|awk -F"," '{print $1}')
echo "The new hot version is $hot_version_new "


# gmconfig=/pub_code/new/backend_ky_test_1.8.0/protected/apps/zg/config/api.yml
  gmconfig=/pub_code/new/backend_ky_42/protected/apps/zg/config/api.yml
  echo -e "\e[034mChanging GM Backend Version\e[0m"
  gmversion=$(ssh   root@10.10.41.101 "grep -A2 production $gmconfig|awk -F":" '/hotver/{print \$2}'")
  echo "$gmversion"
  echo -e "\e[034mThe Current GM Backend Version is $gmversion\e[0m"
  gmversion_new=${hot_version_new}
  echo -e "\e[034mThe New GM Backend Version Will be Changed to $gmversion_new\e[0m"
  ssh -t  root@10.10.41.101  "sudo sed  -i  "/production/,+2s/hotver:$gmversion/hotver:$gmversion_new/"  $gmconfig"

