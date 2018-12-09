
 version=$1
 platform=dream_ios

 songshen_redis_port=6411


#svn up code from svn

if [ "$version" != "" ];then

echo -e  "\n**************SVN UP CODE FROM SVN AND UPLOAD RESOURCE TO CDN***********\n"

ssh -t  wangdeyuan@101.231.68.46 "ssh caribbean@10.10.41.20 'cd /data/tools/prod/$platform;sh update_jialebi_songshen.sh $platform $version'" 


 sudo service php-fpm reload 
           
sudo service redis$songshen_redis_port stop
sudo rsync -avz /data/songshen/$platform/game_server/$platform.$version.rdb /var/lib/redis/dump${songshen_redis_port}\_${platform}\_main_songshen.rdb
sudo service redis$songshen_redis_port start

else
  echo -e  "\e[033mversion number must be given\e[0m"
fi                    

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
