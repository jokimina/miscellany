#!/bin/bash

platform=$1
version=$2

YIWAN="jialebi-haiwai-demo"
Ucloud_CDN="60.191.203.70"
function update_cdn () {
cdndir=/data/cdn_data/resource/$platform/$version/
prod_svn_dir=/data/svn/prod/$platform/$version
hot_file=cdn/hot_version.txt
hot_file_version_old=$(awk -F":" '/hot_version/{print $2}' cdn/hot_version.txt)
hot_file_version_new=$(awk -F":" '/hot_version/{print $2}' /data/jialebi_app/$platform/game_server/hot_version.txt)
hot_version_dir=$version.$hot_file_version_new


echo -e  "\e[33mThe old version is $hot_file_version_old\e[0m"
echo -e "\e[33mThe new version will be updated from $hot_file_version_old to $hot_file_version_new\e[0m"
sudo   sed -i "/hot_version/s/$hot_file_version_old/$hot_file_version_new/" $hot_file
cat $hot_file
cp  $hot_file $prod_svn_dir/game_server/
rsync -avz  $hot_file    $YIWAN::$platform/game_server/
sudo rsync -avz    --exclude ".svn"  $prod_svn_dir/game_server/data/formula/    $YIWAN::$platform/game_server/data/formula/

sudo rsync -avz $cdndir/*  --exclude ".svn"    cdn/$hot_version_dir 
#sudo rsync -avz cdn/$hot_version_dir  disney_svn/resources/android/
#sudo svn cleanup disney_svn/resources/android/
#sudo svn add disney_svn/resources/android/$hot_version_dir
#sudo svn commit disney_svn/resources/android/$hot_version_dir -m "commit android $hot_version_dir"
#
sudo rsync -avz $prod_svn_dir/$platform.$version.rdb     $YIWAN::$platform/$platform.rdb

#上传资源到Ucloud备用CDN
rsync -avz --exclude ".svn" --progress  cdn/$hot_version_dir/ 60.191.203.70::carribeancdn/haiwai/$hot_version_dir/
                       }

if [ "$platform" != "" -a "$version" != "" ];then 
   update_cdn
else
   echo -e "\e[105mPlatform name and version should be given\e[0m"
   echo -e "\e[105mUsage: $0 dream_android 0.9.1\e[0m"
fi
 
