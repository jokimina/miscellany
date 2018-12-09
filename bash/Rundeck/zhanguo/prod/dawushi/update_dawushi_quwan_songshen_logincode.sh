version=2.2.0
svndir=/svn/kingnet/$version/front_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir   210.65.163.118::kaiyingsongshenlogin
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir   210.65.163.118::xinchangsongshenlogin
