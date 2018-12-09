version=1.7.0
svndir=/svn/channels/$version/front_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/" --exclude "htdoc/resource" --exclude "config"  $svndir    logincode@203.195.181.236::baidulogin  --password-file=/etc/rsyncd.secrets.baidu 

