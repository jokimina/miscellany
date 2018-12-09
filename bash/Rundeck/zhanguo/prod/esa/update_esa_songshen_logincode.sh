version=1.8.0
svndir=/svn/esa/$version/front_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir    54.254.196.119::esasongshenlogin

