version=1.7.0
svndir=/svn/jp/$version/game_server/
svn up $svndir
sudo rsync  -aP   --exclude "data/tools_release_events.php"     --exclude="data/events.php"   --exclude "include/initerioruser.php"  --exclude "include/maintenance.php"      --exclude ".svn/" --exclude "htdoc/resource" --exclude "config/app.conf.php*"  $svndir cdn/hot_version.txt   54.238.140.69::japan 
#sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir    54.238.140.69::japan 

