#platform=jidong
#version=1.0.0

 platform=$1
 version=$2

#check directory exists

if [ -d "/data/songshen/$platform" ];then
   echo "/data/songshen/$platform exists!"
else
   mkdir -p /data/songshen/$platform
fi

if [ -d "/data/cdn_data/resource/$platform/$version" ];then
   echo "/data/cdn_data/resource/$platform/$version exists!"
else
   mkdir -p /data/cdn_data/resource/$platform/$version
fi

if [ -d "/data/gamecode/$platform" ];then
   echo "/data/gamecode/$platform exists!"
else
   mkdir -p /data/gamecode/$platform/{new,backup}
fi


#svn up code from svn


echo -e  "\n**************SVN UP CODE FROM SVN AND UPLOAD RESOURCE TO CDN***********\n"

ssh -t  wangdeyuan@101.231.68.46 "ssh gintama@10.10.41.17 'cd /data/tools/prod/baidu;sh update_gintama_songshen.sh $platform $version'" 

##update version.ini
cd   /data/songshen/$platform/game_code/config/$platform/
cp version_old.ini version.ini

 sudo service php-fpm reload 
           

#gmconfig=/var/www/html/zhanguo-backend-dev/protected/apps/zg/config/api.yml

#hot_version_update=$(awk -F":" '/hot_version/{print $2}' /data/zhanguo_demo_gamecode/apple/hot_version.txt)

#echo -e "\e[034mChanging GM Backend Version\e[0m"
#gmversion=$(ssh   wangdeyuan@101.231.68.46 "grep -A3 production $gmconfig|awk -F":" '/myriad_hotver/{print \$2}'")
#echo "$gmversion"
#echo -e "\e[034mThe Current GM Backend Version is $gmversion\e[0m"
#gmversion_new=${hot_version_update}
#echo -e "\e[034mThe New GM Backend Version Will be Changed to $gmversion_new\e[0m"
#ssh -t  wangdeyuan@101.231.68.46  "sudo sed  -i  "/production/,+3s/myriad_hotver:$gmversion/myriad_hotver:$gmversion_new/
#"  $gmconfig"
