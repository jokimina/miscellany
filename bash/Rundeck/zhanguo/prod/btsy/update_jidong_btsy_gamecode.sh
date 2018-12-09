version=1.0.0
svndir=/svn/btsy/$version/game_server/
svn up $svndir
sudo rsync  -aP    --exclude="data/events.php"        --exclude "include/initerioruser.php"  --exclude "include/maintenance.php"   --exclude "data/tools_release_events.php"      --exclude ".svn/" --exclude "htdoc/resource" --exclude "config/app.conf.php"  --exclude "include/maintenance.php"     $svndir cdn/hot_version.txt   btsycode@101.66.253.145::btsy  

