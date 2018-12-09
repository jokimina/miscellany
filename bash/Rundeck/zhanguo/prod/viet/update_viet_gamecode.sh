version=1.8.0
svndir=/svn/yn/$version/

svn up $svndir
sudo rsync  -aP   --exclude="data/events.php"   --exclude "data/tools_release_events.php"  --exclude "include/initerioruser.php"  --exclude "include/maintenance.php"      --exclude ".svn/" --exclude "htdoc/resource" --exclude "config/app.conf.php*"  $svndir/game_server/ cdn/hot_version.txt   203.162.69.63::viet 
sudo rsync -aP    --exclude="config/" --exclude=".svn" $svndir/front_server/ 203.162.69.63::viet_login
#sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir    54.238.140.69::japan 

