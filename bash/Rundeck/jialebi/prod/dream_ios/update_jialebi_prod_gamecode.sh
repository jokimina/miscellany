platform=$1
version=$2

 YIWAN="srv-disney-pirates-demo"
function update_code () {

      prod_svn_dir=/data/svn/prod/$platform/$version/
      svn up $prod_svn_dir
      sudo rsync -avz    --exclude "config/" --exclude ".svn" --exclude "htdoc/"  --exclude "www/" --exclude "data"  $prod_svn_dir/game_server    $YIWAN::$platform
      sudo rsync -avz    --exclude "config/" --exclude ".svn"   $prod_svn_dir/game_center    $YIWAN::$platform
      sudo rsync -avz    --exclude "*.log" --exclude ".svn" $prod_svn_dir/game_public   $YIWAN::$platform
#      sudo rsync -avz $prod_svn_dir/$platform.$version.rdb     $YIWAN::$platform/$platform.rdb 
                        }

if [ "$platform" != "" -a "$version" != "" ];then
   update_code
else
   echo -e "\e[105mPlatform name and version should be given\e[0m"
   echo -e "\e[105mUsage: $0 dream_ios 0.9.1\e[0m"
fi
