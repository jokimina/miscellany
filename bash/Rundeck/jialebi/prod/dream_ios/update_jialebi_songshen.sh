platform=$1
version=$2
function update_code () {
 YIWAN="srv-disney-pirates-demo"
    prod_svn_dir=/data/svn/prod/$platform/$version/
    cdn_dir=/data/cdn_data/resource/$platform/$version/
    svn up $prod_svn_dir
    sudo rsync -avz    --exclude "config/" --exclude ".svn" --exclude "htdoc/"  --exclude "www/" --exclude "data/operator/"  $prod_svn_dir/game_server    $YIWAN::${platform}_songshen
    sudo rsync -avz    --exclude "config/" --exclude ".svn"  $prod_svn_dir/game_center    $YIWAN::${platform}_songshen
    sudo rsync -avz    --exclude "*.log" --exclude ".svn" $prod_svn_dir/game_public/      $YIWAN::${platform}_songshen/game_server/www/prod/s1/
    sudo rsync -avz    --exclude ".svn" $cdn_dir/ $YIWAN::${platform}_cdn
    sudo rsync -avz $prod_svn_dir/$platform.$version.rdb     $YIWAN::${platform}_songshen/game_server/

                        }

if [ "$platform" != "" -a "$version" != "" ];then
   update_code
else
   echo -e "\e[105mPlatform name and version should be given\e[0m"
   echo -e "\e[105mUsage: $0 dream_ios 0.9.2\e[0m"
fi
