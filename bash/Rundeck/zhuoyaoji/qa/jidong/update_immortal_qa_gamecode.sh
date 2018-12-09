#!/bin/bash
platform=$1
new_version=${2-false} 
version=$3
diff_version=$4

qa_svn_gamecode_dir=/data/svn/qa/$platform/$version/
#环境
environment=qa
#debug
#set -x 

server_list=$(cat /tmp/server_list.txt)
if [ "$new_version" == "false" ];then
   qa_logincode_dir=/data/immortal_app/$platform/
   qa_gamecode_dir=/data/immortal_app/$platform/
else   
   qa_logincode_dir=/data/immortal_app/${platform}_new/
   qa_gamecode_dir=/data/immortal_app/${platform}_new/
fi

function update_code () {
    echo '--exclude ".svn/"   --exclude ".svn" --exclude "conf/"  --exclude "dev/" --exclude "local/" --exclude "logs/" --exclude "vendor/" --exclude "xls/"   --exclude "index.php" hotupdate/' 
    #同步代码
    echo "sync gamecode .."
    rsync -avz     --exclude ".svn/"   --exclude ".svn" --exclude "conf/" --exclude "static/" --exclude "dev/" --exclude "local/" --exclude "logs/" --exclude "vendor/" --exclude "xls/"   --exclude "index.php" --exclude "hotupdate/" $qa_svn_gamecode_dir/  $qa_gamecode_dir
    #同步策划资源
    echo "sync design resource.."
    rsync -avz --delete --exclude ".svn" $qa_svn_gamecode_dir/static/ $qa_gamecode_dir/static/

    #cp $qa_gamecode_dir/config/$platform/version_old.ini $qa_gamecode_dir/config/$platform/version.ini 
    cd /data/immortal_app/$platform

    if [ $diff_version != "Null" ];then
	    echo "############################  start export cdn resource!! ############################"
	    [ ! -d /data/cdn_data/resource/$platform/$version ] && sudo mkdir -p /data/cdn_data/resource/$platform/$version
	    #更新CDN
	    tmp_cdn_dir=/data/svn/cdn_data/resource/$platform/$version
	    cdn_dir=/data/cdn_data/resource/$platform/$version
	    sudo rsync -avz $tmp_cdn_dir/  $cdn_dir/
	    echo "php  public/index.php -p $platform -e $environment -s 1 -i version/update/v/$version"
	    php  public/index.php -p $platform -e $environment -s 1 -i version/update/v/$version
    fi

 
    sudo service php-fpm reload

                        }
if [ "$platform" != ""  -a "$version" != "" ];then
   update_code
else
   echo -e "\e[105mPlatform name should be given\e[0m"
   echo -e "\e[105mUsage: $0  jidong false 1.0.0\e[0m"
fi
