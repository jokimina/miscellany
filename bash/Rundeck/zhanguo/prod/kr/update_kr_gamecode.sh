version=1.7.0
svndir=/svn/kr/$version/game_server/
svn up $svndir
sudo rsync  -aP  --exclude="data/events.php"     --exclude ".svn/" --exclude "htdoc/resource" --exclude "config"  --exclude "include/maintenance.php"    $svndir   cdn/hot_version.txt    210.65.163.115::kr

sudo rsync  -aP  --exclude="data/events.php"       --exclude ".svn/" --exclude "htdoc/resource" --exclude "config"  --exclude "include/maintenance.php"   $svndir   cdn/hot_version.txt    210.65.163.115::kr
