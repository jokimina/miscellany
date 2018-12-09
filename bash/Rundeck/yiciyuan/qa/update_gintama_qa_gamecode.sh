#!/bin/bash
#set -x
platform=$1
new_version=${2-false}
version=$3
qa_svn_gamecode_dir=/data/svn/qa/$platform/$version/game_code/
# 

if [ "$new_version" == "false" ];then
   qa_logincode_dir=/data/gintama_app/$platform/game_code/
   qa_gamecode_dir=/data/gintama_app/$platform/game_code/
else   
   qa_logincode_dir=/data/gintama_app/${platform}_new/game_code/
   qa_gamecode_dir=/data/gintama_app/${platform}_new/game_code/
fi

function update_code () {
  
#    rsync -avz --exclude=".svn" --exclude="config/"  --exclude="log"    $qa_svn_gamecode_dir/  $qa_gamecode_dir
    rsync -avz --exclude=".svn" --exclude="config/"   $qa_svn_gamecode_dir/  $qa_gamecode_dir
    rsync -avz --exclude=".svn"   $qa_svn_gamecode_dir/config/$platform/sensitive_words.php  $qa_gamecode_dir/config/$platform/
    rsync -avz --exclude=".svn"   $qa_svn_gamecode_dir/config/$platform/rand_name.php  $qa_gamecode_dir/config/$platform/
    cp $qa_gamecode_dir/config/$platform/version_old.ini $qa_gamecode_dir/config/$platform/version.ini 
 
if [ $platform == "jidongadr" ];then
    rsync -avz --exclude=".svn"   $qa_svn_gamecode_dir/config/$platform/sensitive_words.php  $qa_gamecode_dir/config/bdyy/
    rsync -avz --exclude=".svn"   $qa_svn_gamecode_dir/config/$platform/rand_name.php  $qa_gamecode_dir/config/bdyy/
    cp $qa_gamecode_dir/config/bdyy/version_old.ini $qa_gamecode_dir/config/bdyy/version.ini 
fi
    sudo service php-fpm reload


                        }
if [ "$platform" != ""  -a "$version" != "" ];then
   update_code
else
   echo -e "\e[105mPlatform name should be given\e[0m"
   echo -e "\e[105mUsage: $0  jidong false 1.0.0\e[0m"
fi
