version=1.7.0
svndir=/svn/channels/1.7.0/game_server/
svn up $svndir
sudo rsync        -aP    --exclude "include/initerioruser.php"  --exclude "include/maintenance.php"         --exclude="data/events.php"    --exclude "config/app.conf.php*"  --exclude "htdoc/resource/*" --exclude ".svn/"   $svndir cdn/hot_version.txt  360code@101.66.253.145::360  --password-file=/etc/rsyncd.secrets.360 

