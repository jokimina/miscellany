version=1.2.0
platform=xinchang
svndir=/svn/$platform/$version/front_server/
svn up $svndir
sudo rsync  -aP   --exclude "config/app.conf.php*"  --exclude "library/sdk/yilian/"    --exclude "include/maintenance.php"      --exclude ".svn/"   $svndir   101.66.253.145::channels_xc_login

