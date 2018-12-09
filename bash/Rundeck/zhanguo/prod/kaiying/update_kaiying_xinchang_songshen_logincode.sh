version=2.1.3
svndir=/svn/kingnet/$version/front_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir   210.65.163.118::kaiyingsongshenlogin
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir   210.65.163.118::xinchangsongshenlogin
