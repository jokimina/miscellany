version=1.7.1
svndir=/svn/kaiying/$version/front_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir   210.65.163.118::xinchangsongshenlogin
