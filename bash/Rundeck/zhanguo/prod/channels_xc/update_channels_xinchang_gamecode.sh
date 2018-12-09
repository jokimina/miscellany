version=1.2.0
platform=xinchang
svndir=/svn/$platform/$version/game_server/
svn up $svndir
sudo rsync        --exclude="data/events.php"  --exclude "data/tools_release_events.php"   --exclude "include/initerioruser.php"  --exclude "include/maintenance.php"        -aP   --exclude "config/app.conf.php*"  --exclude "htdoc/resource/*" --exclude ".svn/"   $svndir cdn/hot_version.txt  101.66.253.145::channels_xc

