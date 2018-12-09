version=1.0.0
svndir=/svn/xinchang/$version/front_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir    btsycode@101.66.253.145::xinchangsongshenlogin  --password-file=/etc/rsyncd.secrets.btsy 

