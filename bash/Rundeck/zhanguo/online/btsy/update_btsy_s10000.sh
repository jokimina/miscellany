#svn up code from svn

echo -e  "\n**************SVN UP CODE FROM SVN AND UPLOAD RESOURCE TO CDN***********\n"

ssh -t  wangdeyuan@101.231.68.46 "ssh sengoku@10.10.41.42 'cd /data/tools/updatecode/btsy/;sh update_jidong_btsy_CDN_resource.sh;sh update_jidong_btsy_gamecode.sh'" 


#update s10000
 platform=btsy

 version=1.0.0


 hot_version_old=$(awk '/hot_version/{print $3}'  /data/zhanguo_demo_gamecode/$platform/config/app.conf.php|awk -F"," '{print $1}')

echo -e  "\n*********************BACKUP S10000 FILES****************\n"

##backup s10000 code
 rsync -avz  /data/zhanguo_demo_gamecode/$platform/  --exclude "htdoc/resource/*" --exclude ".svn/"   /data/gamecode/$platform/backup/$version.$hot_version_old
 cd /data/gamecode/$platform/new/

##update s10000 code
 rsync     -aP      --exclude="data/events.php"    --exclude "data/tools_release_events.php"        --exclude "config/app.conf.php*"  --exclude "htdoc/resource/*" --exclude ".svn/"   --exclude "include/initerioruser.php"  --exclude "include/maintenance.php"      *  hot_version.txt    /data/zhanguo_demo_gamecode/$platform/

 hot_version_update=$(awk -F":" '/hot_version/{print $2}' hot_version.txt)
 sed  -i   -e "/hot_version/s/$hot_version_old/$hot_version_update/"  -e  "/hot_update_url/s/$version.$hot_version_old/$version.$hot_version_update/"   /data/zhanguo_demo_gamecode/$platform/config/app.conf.php
 sudo service php-fpm reload 

 grep -E --color 'hot_version|hot_update_url' /data/zhanguo_demo_gamecode/$platform/config/app.conf.php|mail -s "Updating Jidong Platform S10000 Code  On $(date +%Y/%m/%d/%H/%M)  Operated by $USER"  wangdy@jidonggame.com




gmconfig=/var/www/html/zhanguo-btsy-backend-dev/protected/apps/zg/config/api.yml

hot_version_update=$(awk -F":" '/hot_version/{print $2}' /data/zhanguo_demo_gamecode/btsy/hot_version.txt)

echo -e "\e[034mChanging GM Backend Version\e[0m"
gmversion=$(ssh   wangdeyuan@101.231.68.46 "grep -A3 production $gmconfig|awk -F":" '/myriad_hotver/{print \$2}'")
echo "$gmversion"
echo -e "\e[034mThe Current GM Backend Version is $gmversion\e[0m"
gmversion_new=${hot_version_update}
echo -e "\e[034mThe New GM Backend Version Will be Changed to $gmversion_new\e[0m"
ssh -t  wangdeyuan@101.231.68.46  "sudo sed  -i  "/production/,+3s/myriad_hotver:$gmversion/myriad_hotver:$gmversion_new/"  $gmconfig"
