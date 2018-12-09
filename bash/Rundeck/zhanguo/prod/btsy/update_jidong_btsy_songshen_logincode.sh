version=2.1.0
svndir=/svn/btsy/$version/front_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir    btsycode@101.66.253.145::btsysongshenlogin  --password-file=/etc/rsyncd.secrets.btsy 

