version=1.7.0
svndir=/svn/kr/$version/front_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir   210.65.163.115::krsongshenlogin
