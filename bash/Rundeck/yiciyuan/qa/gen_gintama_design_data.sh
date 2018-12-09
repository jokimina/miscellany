#!/bin/bash
#generate design resource data from desgin svn branch

#define variables
platform=$1
revision_tag=$2
version_tag=$(echo $revision_tag|awk -F"." '{print $1"."$2"."$3}')
tag=$(echo $revision_tag|awk -F"." '{print $4}')
new_version=${3-false}
version=$4

#debug
#set -x

if [ "$version" != "$version_tag" ];then
   version=$version_tag
fi
design_svn_base=https://svn.jidongnet.com/svn/GINTAMA/dev/hot_resource/tag/
cdn_dir=/data/cdn_data/resource/$platform/$version
dev_svn_dir=/data/svn/dev/

if [ "$new_version" == "false" ];then
   qa_gamecode_dir=/data/gintama_app/$platform/game_code
else
   qa_gamecode_dir=/data/gintama_app/${platform}_new/game_code
fi

##### create version_old.ini

if [ ! -f "$qa_gamecode_dir/config/$platform/version_old.ini" ];then
   echo "$qa_gamecode_dir/config/$platform/version_old.ini not exists!"
   cp $qa_gamecode_dir/config/$platform/version.ini $qa_gamecode_dir/config/$platform/version_old.ini
   if [ $platform == "jidongadr" ];then
   	cp $qa_gamecode_dir/config/$platform/version.ini $qa_gamecode_dir/config/bdyy/version_old.ini
   fi
fi

##
#/data/gintama_app/jidong/game_code/config/jidong/version.ini
base_version_old=$(grep base_version $qa_gamecode_dir/config/$platform/version_old.ini|awk '{print $3}')
hot_version_old=$(grep  hot_version $qa_gamecode_dir/config/$platform/version_old.ini|awk '{print $3}'|uniq)

if [ "$platform" != "" -a "$revision_tag" != "" ];then     
  svn export $design_svn_base/$platform/$revision_tag   $cdn_dir/$tag   --force	
  sed  -i -e  "/base_version/s/$base_version_old/$tag/g" -e "/hot_version/s/$hot_version_old/$tag/g"   $qa_gamecode_dir/config/$platform/version_old.ini
  if [ $platform == "jidongadr" ];then
	 sed  -i -e  "/base_version/s/$base_version_old/$tag/g" -e "/hot_version/s/$hot_version_old/$tag/g"   $qa_gamecode_dir/config/bdyy/version_old.ini 
  fi
else
  echo -e "\e[105mPlatform name and revision string  should be given\e[0m"
  echo -e "\e[105mUsage: $0 qagintama 1.0.0.2 true\e[0m"
fi   


