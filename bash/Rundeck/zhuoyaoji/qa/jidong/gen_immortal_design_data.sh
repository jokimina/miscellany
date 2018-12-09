#!/bin/bash
#generate design resource data from desgin svn branch

#debug
set -x
#define variables
#CDN资源
cdn_difference_tag=$1
#策划资源
design_difference_tag=$2
#平台
platform=$3
#是否为高版本
new_version=${4-false}
#版本号
version=$5

function init(){
		design_svn_base=https://svn.jidongnet.com/svn/immortal/dev/hot_resource/trunk/
		dev_svn_dir=/data/svn/dev/
		
		if [ "$new_version" == "false" ];then
		   qa_gamecode_dir=/data/immortal_app/$platform/game_code
		else
		   qa_gamecode_dir=/data/immortal_app/${platform}_new/game_code
		fi
	

}


function get_design_resource(){
	svn_resource_dir=https://svn.jidongnet.com/svn/immortal/dev/server_resource/tag/$platform/$version.$design_difference_tag/
	resource_dir=/data/svn/qa/$platform/$version/
	sudo chown immortal:operation $resource_dir
	svn export $svn_resource_dir/ $resource_dir  --force
	
}

function get_resource(){
          tmp_cdn_dir=/data/svn/cdn_data/resource/$platform/$version
	  [ ! -d $tmp_cdn_dir ]	 && sudo mkdir -p  $tmp_cdn_dir
	  sudo chown immortal:operation -R $tmp_cdn_dir/
	  echo $tmp_cdn_dir

	  echo "###################    to CDN    #####################"
	  svn export $design_svn_base/$platform/$version/   $tmp_cdn_dir/   --force	

}

if [ "$cdn_difference_tag" != "Null" -o "$design_difference_tag" != "Null" ];then     
	init 
	if [ "$cdn_difference_tag" != "Null" ];then
		get_resource
	elif [ "$design_difference_tag" != "Null" ];then
		get_design_resource
	fi
else
  echo "you need a tag !!!!!" 
  exit 10
  echo -e "\e[105mPlatform name and revision string  should be given\e[0m"
  echo -e "\e[105mUsage: $0 qagintama 1.0.0.2 true\e[0m"
fi   


