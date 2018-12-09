#!/bin/bash
platform=apple
version=2.1.0
hot_update_file=/data/svn/$platform/$version/game_server/htdoc/resource/hot_update_file.json
qa_gamecode_dir=/data/zhanguo_app/apple_new/zhanguo_server/
qa_gamecode_dir2=/data/zhanguo_app/apple_new/zhanguo_server_2/
qa_gamecode_dir3=/data/zhanguo_app/apple_new/zhanguo_server_3/
qa_gamecode_dir4=/data/zhanguo_app/apple_new/zhanguo_server_4/

rsync -avz /data/svn/$platform/$version/game_server/  --exclude ".svn" --exclude "config" $qa_gamecode_dir
rsync -avz /data/svn/$platform/$version/game_server/  --exclude ".svn" --exclude "config" $qa_gamecode_dir2
rsync -avz /data/svn/$platform/$version/game_server/  --exclude ".svn" --exclude "config" $qa_gamecode_dir3
rsync -avz /data/svn/$platform/$version/game_server/  --exclude ".svn" --exclude "config" $qa_gamecode_dir4

hot_version_old=$(awk '/hot_version/{print $3}' $qa_gamecode_dir/config/app.conf.php|awk -F"," '{print $1}')
echo "The old hot version is $hot_version_old"
hot_version_update=$(awk -F"," '/version/{print $1}' $hot_update_file|awk -F":" '{print $2}')

echo "The update hot version is $hot_version_update"

sed -i "/hot_version/s/$hot_version_old/$hot_version_update/" $qa_gamecode_dir/config/app.conf.php  $qa_gamecode_dir2/config/app.conf.php  $qa_gamecode_dir3/config/app.conf.php  $qa_gamecode_dir4/config/app.conf.php


hot_version_new=$(awk '/hot_version/{print $3}' $qa_gamecode_dir/config/app.conf.php|awk -F"," '{print $1}')
echo "The new hot version is $hot_version_new "
