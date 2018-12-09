version=2.1.3
svndir=/svn/kingnet/$version/game_server/
svn up $svndir
sudo rsync --progress  -aP     --exclude="data/events.php"  --exclude ".svn/" --exclude "htdoc/resource" --exclude "config/app.conf.php*"  --exclude "include/maintenance.php"   --exclude "include/initerioruser.php"  --exclude "data/tools_release_events.php"     $svndir   cdn/hot_version.txt    210.65.163.118::kaiying

sudo rsync  --progress   -aP     --exclude="data/events.php"          --exclude ".svn/" --exclude "htdoc/resource" --exclude "config/app.conf.php*"  --exclude "include/maintenance.php"  --exclude "include/initerioruser.php"   --exclude "data/tools_release_events.php"   $svndir   cdn/hot_version.txt    210.65.163.118::xinchang
