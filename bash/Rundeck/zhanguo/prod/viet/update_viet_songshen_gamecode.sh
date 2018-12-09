version=1.8.0
svndir=/svn/yn/$version/game_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir    123.30.215.186::vietsongshen

