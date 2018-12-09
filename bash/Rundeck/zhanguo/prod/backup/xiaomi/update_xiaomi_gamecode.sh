version=1.6.0
svndir=/svn/xiaomi/$version/game_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/" --exclude "htdoc/resource" --exclude "config"  $svndir cdn/hot_version.txt   101.66.253.145::xiaomi

