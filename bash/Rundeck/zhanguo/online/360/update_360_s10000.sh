 platform=360
 version=1.7.0
 rsync -avz  /data/zhanguo_demo_gamecode/$platform/  --exclude "htdoc/resource/*" --exclude ".svn/"   /data/gamecode/$platform/backup/$(date +%Y-%m-%d-%H-%M)
 cd /data/gamecode/$platform/new/
 rsync     -aP   --exclude "config/app.conf.php*"  --exclude "htdoc/resource/*" --exclude ".svn/" data xml *  hot_version.txt    /data/zhanguo_demo_gamecode/$platform/
 hot_version_old=$(awk '/hot_version/{print $3}'  /data/zhanguo_demo_gamecode/$platform/config/app.conf.php|awk -F"," '{print $1}')
 hot_version_update=$(awk -F":" '/hot_version/{print $2}' hot_version.txt)
 sed  -i   -e "/hot_version/s/$hot_version_old/$hot_version_update/"  -e  "/hot_update_url/s/$version.$hot_version_old/$version.$hot_version_update/"   /data/zhanguo_demo_gamecode/$platform/config/app.conf.php
 sudo service php-fpm reload
 grep -E --color 'hot_version|hot_update_url' /data/zhanguo_demo_gamecode/$platform/config/app.conf.php|mail -s "Updating 360  Platform S10000 Code  On $(date +%Y/%m/%d/%H/%M)  Operated by $USER"  wangdy@jidonggame.com
