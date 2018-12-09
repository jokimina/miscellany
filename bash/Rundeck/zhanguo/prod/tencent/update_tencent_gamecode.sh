version=1.7.1
svndir=/svn/kingnet/$version/game_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/" --exclude "htdoc/resource" --exclude "config"  --exclude "include/maintenance.php"    $svndir   cdn/hot_version.txt    210.65.163.118::kaiying

sudo rsync  -aP  --exclude ".svn/" --exclude "htdoc/resource" --exclude "config"  --exclude "include/maintenance.php"   $svndir   cdn/hot_version.txt    210.65.163.118::xinchang
