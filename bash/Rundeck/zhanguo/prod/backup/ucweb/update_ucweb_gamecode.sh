version=1.7.0
svndir=/svn/channels/1.7.0/game_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/" --exclude "htdoc/resource" --exclude "config"  $svndir cdn/hot_version.txt   101.66.253.145::ucweb

