version=1.3.0
platform=xinchang
svndir=/svn/$platform/$version/game_server/
svn up $svndir
sudo rsync  -aP  --exclude ".svn/"  --exclude "config"  $svndir   60.191.203.12::channels_xinchangsongshen
