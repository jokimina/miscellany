 type=$1
 change_version=$2

# platform=dream_ios
# version=1.0.6
platform=$3
version=$4

function update_code () {

        echo -e  "\n**************SVN UP CODE FROM SVN AND UPLOAD RESOURCE TO CDN***********\n"

#ssh -t  wangdeyuan@101.231.68.46 "ssh caribbean@10.10.41.20 'cd /data/tools/prod/dream_ios;sh update_jialebi_prod_CDN.sh dream_ios $version;sh update_jialebi_prod_gamecode.sh  dream_ios $version'" 
        ssh -t  wangdeyuan@101.231.68.46 "ssh caribbean@10.10.41.20 'cd /data/tools/prod/dream_ios;sh update_jialebi_prod_gamecode.sh  dream_ios $version'" 

        echo -e  "\n*********************BACKUP S10000 FILES****************\n"

        ##backup s10000 code
        rsync -avz  /data/jialebi_demo_gamecode/$platform/game_server/   --exclude ".svn/"   /data/gamecode/$platform/backup/$version.$hot_version_old

        cd /data/gamecode/$platform/new/

        ##update s10000 code
        rsync  -avz  --exclude ".svn" --exclude "config/"  --exclude "www/"     game_server/      /data/jialebi_demo_gamecode/$platform/game_server/
        rsync -avz --exclude ".svn" game_public/ /data/jialebi_demo_gamecode/$platform/game_server/www/prod/s10000/

        sudo service php-fpm reload 

                }


function  update_resource () {

        ssh -t  wangdeyuan@101.231.68.46 "ssh caribbean@10.10.41.20 'cd /data/tools/prod/dream_ios;sh update_jialebi_prod_CDN.sh dream_ios $version'" 

        hot_version_update=$(awk -F":" '/hot_version/{print $2}' /data/gamecode/$platform/new/game_server/hot_version.txt)

        cdn_version_old=$(awk '/cdn_version/{print $3}' /data/jialebi_demo_gamecode/$platform/game_server/config/application.conf.php|awk -F"'" '{print $2}')

        cdn_url_version_old=$(awk -F"/" '/cdn_url/{print $(NF-1)}'  /data/jialebi_demo_gamecode/$platform/game_server/config/application.conf.php|awk -F"." '{print $NF}')      

        version_old=$(awk '/cdn_url/{print $3}' /data/jialebi_demo_gamecode/dream_ios/game_server/config/application.conf.php|sed -e "s#'##g" -e "s#http://pirates.i.dol.cn/itunes/pirates/resources/##" -e "s#[a-z]*##" -e "s#,##"   -e "s#/##"|awk -F"." '{print $1"."$2"."$3}')

        echo $version_old
  
        if [ "$version" != "$version_old" ];then
           sed -i "/cdn_url/s/$version_old/$version/" /data/jialebi_demo_gamecode/$platform/game_server/config/application.conf.php
        fi

        if [ "$change_version" == "yes" ];then

            sed  -i   -e "/cdn_version/s/$cdn_version_old/$hot_version_update/"  -e  "/cdn_url/s/$version.$cdn_url_version_old/$version.$hot_version_update/"   /data/jialebi_demo_gamecode/$platform/game_server/config/application.conf.php
     
        elif [ "$change_version" == "no" ];then
             
            sed  -i  "/cdn_url/s/$version.$cdn_url_version_old/$version.$hot_version_update/"   /data/jialebi_demo_gamecode/$platform/game_server/config/application.conf.php
         
        else   
            echo "Wrong argument"
    
        fi

        sudo service redis6410 stop
        sudo rsync -avz /data/gamecode/dream_ios/new/dream_ios.rdb /var/lib/redis/dump6410_dream_ios_main_s10000.rdb 
        sudo service redis6410 start

        rsync -avz /data/gamecode/$platform/new/game_server/data/formula/    /data/jialebi_demo_gamecode/$platform/game_server/data/formula/
                            }

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
