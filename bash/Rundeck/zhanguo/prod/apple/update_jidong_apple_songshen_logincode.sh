version=2.1.0
svndir=/svn/apple/$version/front_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir    applecode@101.66.253.145::applesongshenlogin  --password-file=/etc/rsyncd.secrets.apple 

