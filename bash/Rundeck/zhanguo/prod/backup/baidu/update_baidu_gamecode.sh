version=1.7.0
svndir=/svn/channels/$version/game_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/" --exclude "htdoc/resource" --exclude "config"  $svndir cdn/hot_version.txt   baiducode@203.195.181.236::baidu  --password-file=/etc/rsyncd.secrets.baidu 

