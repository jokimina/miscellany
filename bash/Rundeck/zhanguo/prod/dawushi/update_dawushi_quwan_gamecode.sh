version=1.0.0
svndir=/svn/dawushi/$version/game_server/
svn up $svndir
sudo rsync  -aP     --exclude="data/events.php"  --exclude ".svn/" --exclude "htdoc/resource" --exclude "config/app.conf.php*"  --exclude "include/maintenance.php"   --exclude "include/initerioruser.php"  --exclude "data/tools_release_events.php"     $svndir   cdn/hot_version.txt    210.242.196.156::dawushi
