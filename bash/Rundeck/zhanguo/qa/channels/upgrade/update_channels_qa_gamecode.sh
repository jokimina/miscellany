#!/bin/bash
platform=channels
version=1.7.1
hot_update_file=/data/svn/$platform/$version/game_server/htdoc/resource/hot_update_file.json
qa_gamecode_dir=/data/zhanguo_app/360_new/zhanguo_server/
rsync -avz /data/svn/$platform/$version/game_server/  --exclude ".svn" --exclude "config"  --exclude "data/events.php"      $qa_gamecode_dir

hot_version_old=$(awk '/hot_version/{print $3}' $qa_gamecode_dir/config/app.conf.php|awk -F"," '{print $1}')
echo "The old hot version is $hot_version_old"
hot_version_update=$(awk -F"," '/version/{print $1}' $hot_update_file|awk -F":" '{print $2}')

echo "The update hot version is $hot_version_update"

sed -i "/hot_version/s/$hot_version_old/$hot_version_update/" $qa_gamecode_dir/config/app.conf.php


hot_version_new=$(awk '/hot_version/{print $3}' $qa_gamecode_dir/config/app.conf.php|awk -F"," '{print $1}')
echo "The new hot version is $hot_version_new "
