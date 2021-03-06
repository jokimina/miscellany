#!/bin/bash
#set -x
platform=$1
new_version=${2-false}
version=$3
qa_svn_gamecode_dir=/data/svn/qa/$platform/$version/game_server/
qa_svn_pubcode_dir=/data/svn/qa/$platform/$version/game_public/
cdn_url_base=http://jialebi-qa-cdn.jidongnet.com/$platform
game_route_dir=/data/jialebi_app/dream_game_router/htdoc/
android_login_url=jialebi-qa-login.jidongnet.com
android_login_url_new=jialebi-qa-new-login.jidongnet.com
ios_login_url=jlb-ios-qa-login.jidongnet.com
ios_login_url_new=jlb-ios-qa-new-login.jidongnet.com

if [ "$new_version" == "false" ];then
   qa_logincode_dir=/data/jialebi_app/$platform/game_center/
   qa_gamecode_dir=/data/jialebi_app/$platform/game_server
else   
   qa_logincode_dir=/data/jialebi_app/${platform}_new/game_center/
   qa_gamecode_dir=/data/jialebi_app/${platform}_new/game_server
fi

function update_code () {
    rsync -avz /data/svn/qa/$platform/$version/game_center/  --exclude ".svn" --exclude "config/" $qa_logincode_dir 
  
#    rsync -avz --exclude=".svn" --exclude="config/" --exclude="www/"   --exclude="htdoc/"  --exclude="www/"  --exclude="data/"     $qa_svn_gamecode_dir/  $qa_gamecode_dir
    rsync -avz --exclude=".svn" --exclude="config/"    --exclude="htdoc/"   --exclude="data/"     $qa_svn_gamecode_dir/  $qa_gamecode_dir

    rsync -avz --exclude=".svn" --exclude="tools/"      $qa_svn_pubcode_dir/     $qa_gamecode_dir/www/prod/s1/ 
    rsync -avz --exclude=".svn" --exclude="tools/"      $qa_svn_pubcode_dir/     $qa_gamecode_dir/www/prod/s2/ 
    rsync -avz --exclude=".svn" --exclude="tools/"      $qa_svn_pubcode_dir/     $qa_gamecode_dir/www/prod/s3/
    rsync -avz --exclude=".svn" --exclude="tools/"      $qa_svn_pubcode_dir/     $qa_gamecode_dir/www/prod/s4/

    sudo service php-fpm reload

                        }

function update_config_version() {
#1.0.4.0
    loginconfig_version=$(grep "current_version"  $qa_logincode_dir/config/application.conf.php|sed -n -e "s/'//g" -e "s/\,//p"|awk '{print $3}')
    loginconfig_version2=$(echo $loginconfig_version|awk -F"." '{print $1"."$2"."$3}')
#1.0.4

    cdn_url_version=$(awk  '/cdn_url/{print $3}' $qa_gamecode_dir/config/application.conf.php|sed -n -e "s/'//g" -e 's/\,//p'|sed -e  "s;$cdn_url_base;;" -n  -e  's;/;;gp')

    if [ "$loginconfig_version2" == "$version" ];then
       echo "game_center config version is right"
    else
       echo "change game_center config version $loginconfig_version to ${version}.0 "
       sed -i "/current_version/s/$loginconfig_version/${version}.0/" $qa_logincode_dir/config/application.conf.php 
    fi

    if [ "$cdn_url_version" == "$version" ];then
       echo "game_server cdn url version is right"
    else
       echo "change game_server cdn url  version $cdn_url_version to $version "
       sed -i "/cdn_url/s/$cdn_url_version/$version/" $qa_gamecode_dir/config/application.conf.php  
    fi 

#check game route url settings
    cd $game_route_dir
    cp index.php  index.php$(date +%Y%m%d)
    

                                 }
if [ "$platform" != ""  -a "$version" != "" ];then
   update_code
   update_config_version
else
   echo -e "\e[105mPlatform name should be given\e[0m"
   echo -e "\e[105mUsage: $0  dream_android (true) 0.9.1\e[0m"
fi
