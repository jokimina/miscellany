version=2.1.3
svndir=/svn/kingnet/$version/game_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir   210.65.163.118::kaiyingsongshen
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir   210.65.163.118::xinchangsongshen
