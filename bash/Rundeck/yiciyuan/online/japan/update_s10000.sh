#type=all,code,resource
#platform=jidong
#version=1.0.0

 type=$1

 platform=$2
 version=$3

#check dirtory
if [ -d "/data/gintama_demo_gamecode/$platform" ];then
   echo "/data/gintama_demo_gamecode/$platform exists!"
else
   sudo  mkdir -p /data/gintama_demo_gamecode/$platform
   sudo chown -R gintama:operation /data/gintama_demo_gamecode/$platform
fi


if [ -d "/data/gamecode/$platform" ];then
   echo "/data/gamecode/$platform exists!"
else
   sudo   mkdir -p /data/gamecode/$platform/{new,backup}
   sudo chown -R gintama:operation /data/gamecode/$platform/{new,backup}
fi

if [ -d "/data/gamecode/$platform/new/game_code/config/$platform/" ];then
   echo "/data/gamecode/$platform/new/game_code/config/$platform  exists!"
else
   sudo    mkdir -p /data/gamecode/$platform/new/game_code/config/$platform
   sudo chown -R gintama:operation /data/gamecode/$platform/new/game_code/config/$platform
fi


function update_code () {

       #svn up code from svn
       echo -e  "\n**************SVN UP CODE FROM SVN AND UPLOAD RESOURCE TO CDN***********\n"

#       ssh -t  wangdeyuan@101.231.68.46 "ssh caribbean@10.10.41.20 'cd /data/tools/prod/dream_android;sh update_jialebi_prod_CDN.sh dream_android $version;sh update_jialebi_prod_gamecode.sh dream_android $version'" 
       ssh -t  wangdeyuan@101.231.68.46 "ssh gintama@10.10.41.17 'cd /data/tools/prod/$platform;sh   update_gintama_prod_gamecode.sh $platform $version'" 

       echo -e  "\n*********************BACKUP S10000 FILES****************\n"

       ##backup s10000 code
       hot_version_old=$(grep hot_version  /data/gintama_demo_gamecode/$platform/game_code/config/$platform/version.ini|awk '{print $3}'|uniq)
       rsync -avz  /data/gintama_demo_gamecode/$platform/game_code/   --exclude ".svn/"     /data/gamecode/$platform/backup/$version.$hot_version_old

       cd /data/gamecode/$platform/new/

       ##update s10000 code
       rsync  -avz  --exclude ".svn" --exclude "config/"   --exclude "hot_version.txt"  --exclude "data/"     game_code/      /data/gintama_demo_gamecode/$platform/game_code/

       sudo service php-fpm reload 
                            }

function update_resource () {

       ssh -t  wangdeyuan@101.231.68.46 "ssh gintama@10.10.41.17 'cd /data/tools/prod/$platform;sh update_gintama_prod_CDN.sh $platform $version'" 
       
       rsync  -avz  --exclude ".svn"     /data/gamecode/$platform/new/game_code/data      /data/gintama_demo_gamecode/$platform/game_code/
   
       base_version_old=$(grep base_version /data/gintama_demo_gamecode/$platform/game_code/config/$platform/version.ini|awk '{print $3}')
       hot_version_old=$(grep hot_version /data/gintama_demo_gamecode/$platform/game_code/config/$platform/version.ini|awk '{print $3}'|uniq)

        hot_version_update=$(awk -F":" '/hot_version/{print $2}' /data/gamecode/$platform/new/game_code/hot_version.txt)

        sed  -i -e  "/base_version/s/$base_version_old/$hot_version_update/g" -e "/hot_version/s/$hot_version_old/$hot_version_update/g"   /data/gintama_demo_gamecode/$platform/game_code/config/$platform/version.ini                         
                            }
  


if [ "$type" != "" -a "$platform" != "" -a "$version" != "" ];then

                  
case $type in

        code)
           echo -e "\e[105m***********ONLY UPDATE CODE**************\e[0m"
           update_code
           ;;
    resource)
           echo -e "\e[105m***********ONLY UPDATE RESOURCE***********\e[0m"
           update_resource
           
           ;;
         all)
           echo -e "\e[105m***********UPDATE BOTH CODE AND RESOURCE***\e[0m"
           update_code
           update_resource
           ;;
           *)
           echo -e "\e[105m***********ERROR****************************\e[0m"
           ;;
esac
           

else
   echo  -e    "\e[033mUsage: $0 {all,code,resource}   jidong 1.0.0\e[0m"
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
