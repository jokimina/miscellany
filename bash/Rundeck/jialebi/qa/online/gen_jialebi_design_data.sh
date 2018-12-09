#!/bin/bash
#generate design resource data from desgin svn branch

#define variables
platform=$1
revision_tag=$2
version_tag=$(echo $revision_tag|awk -F"." '{print $1"."$2"."$3}')
s0_redis_port=$3
main_redis_port=$4
new_version=${5-false}
#set -x

version=$6

if [ "$version" != "$version_tag" ];then
   version=$version_tag
fi
design_svn_base=https://svn.jidongnet.com/svn/jialebi/dev/resource/tag/
qa_svn_dir=/data/svn/qa/$platform/$version
cdn_dir=/data/cdn_data/resource/$platform/$version
qa_svn_gamecode_dir=/data/svn/qa/$platform/$version/game_server/

if [ "$new_version" == "false" ];then
   game_tmp_xml_dir=/data/jialebi_app/$platform/game_server/htdoc/cdn/xml
   s0_game_tools_dir=/data/jialebi_app/$platform/game_server/www/prod/s0/tools/
   hot_version_file=/data/jialebi_app/$platform/game_server/hot_version.txt
   qa_gamecode_dir=/data/jialebi_app/$platform/game_server
else
   game_tmp_xml_dir=/data/jialebi_app/${platform}_new/game_server/htdoc/cdn/xml
   s0_game_tools_dir=/data/jialebi_app/${platform}_new/game_server/www/prod/s0/tools/   
   hot_version_file=/data/jialebi_app/${platform}_new/game_server/hot_version.txt
   qa_gamecode_dir=/data/jialebi_app/${platform}_new/game_server
fi



function gen_data () {
	
       hot_file_version_old=$(awk -F":" '/hot_version/{print $2}' $hot_version_file)
       hot_file_version_new=$(($hot_file_version_old + 1))
	
	#check cdn resource dir
	if [ -d "$cdn_dir" ];then
	   echo "$cdn_dir exists"
	else
	   mkdir -p $cdn_dir
	fi
	
	
	
	#load desgin data
	mkdir -p   $qa_svn_dir/game_public/tools/temp_svn_data/{xml_output,php_output,resource_output}
	
	# export resource files
        svn export --force -q  $design_svn_base/$platform/$revision_tag/resource   $qa_svn_dir/game_public/tools/temp_svn_data/resource_output
	
	# export xml files
	svn export --force -q  $design_svn_base/$platform/$revision_tag/xml   $qa_svn_dir/game_public/tools/temp_svn_data/xml_output
	svn export --force -q  $design_svn_base/$platform/$revision_tag/skip_xml.txt   $qa_svn_dir/game_public/tools/temp_svn_data/skip_xml.txt
	
	rsync -avz  --exclude ".svn"   --delete  $qa_svn_dir/game_public/tools/temp_svn_data/xml_output/  $game_tmp_xml_dir|awk '$1=="deleting"{print $2}' 
	
	for xml in $(cat $qa_svn_dir/game_public/tools/temp_svn_data/skip_xml.txt|awk -F "\r" '{print $1}')
	do 
	    echo $xml
	    if [ -f  $qa_svn_dir/game_public/tools/temp_svn_data/xml_output/$xml ];then
	      echo    "******$qa_svn_dir/game_public/tools/temp_svn_data/xml_output/$xml ****"
	      sudo  rm -f $qa_svn_dir/game_public/tools/temp_svn_data/xml_output/$xml 
	    fi
	done
	
	
	#copy xml files into resource data dir
	sudo rsync -avz  --delete  --exclude=".svn"    $qa_svn_dir/game_public/tools/temp_svn_data/xml_output/    $qa_svn_dir/game_public/tools/temp_svn_data/resource_output/data/
	
	
	
	# export formula  files
	sudo svn export --force -q  $design_svn_base/$platform/$revision_tag/formula   $qa_svn_dir/game_public/tools/temp_svn_data/php_output
	rsync -avz  --exclude ".svn"   --delete  $qa_svn_dir/game_public/tools/temp_svn_data/php_output/   $qa_svn_dir/game_server/data/formula/|awk '$1=="deleting"{print $2}' 
	
        #sudo rsync -avz --exclude ".svn" $qa_svn_dir/tools/   $qa_svn_dir/game_public/tools/	
	cd  $qa_svn_dir/game_public/tools/
	sudo /usr/bin/php gen_checksum.php
	
	rsync -avz   --delete    $qa_svn_dir/game_public/tools/temp_svn_data/resource_output/    $cdn_dir          
	
	sudo rm -rf $qa_svn_dir/game_public/tools/temp_svn_data/
	
	
	rsync -avz  --exclude=".svn"   $qa_svn_dir/game_public/tools/*.php   $s0_game_tools_dir
	
	## generate xml into redis data
	/data/app_platform/redis/bin/redis-cli -p $s0_redis_port flushall
	
	/usr/bin/php $s0_game_tools_dir/gen_cfg.php
	
	/data/app_platform/redis/bin/redis-cli -p $s0_redis_port save
	
	
	sudo service redis$main_redis_port stop
	sudo   cp  /data/app_data/redis/data/dump$s0_redis_port.rdb  /data/app_data/redis/data/dump$main_redis_port.rdb 
	sudo   cp  /data/app_data/redis/data/dump$s0_redis_port.rdb  $qa_svn_dir/$platform.$version.rdb 
	sudo service redis$main_redis_port start

        sed -i "/hot_version/s/$hot_file_version_old/$hot_file_version_new/"  $hot_version_file


        rsync -avz --exclude=".svn"    $qa_svn_gamecode_dir/data/formula/  $qa_gamecode_dir/data/formula/

                      }

  if [ "$platform" != "" -a "$revision_tag" != "" -a "$s0_redis_port" != "" -a "$main_redis_port" != ""  ];then
     gen_data
  else
     echo -e "\e[105mPlatform name and revision string and s0_redis_port and main_redis_port should be given\e[0m"
     echo -e "\e[105mUsage: $0 dream_android 0.9.1.1 6300 6400 true\e[0m"
  fi   


