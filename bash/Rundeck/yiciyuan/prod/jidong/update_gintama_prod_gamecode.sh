#platform=jidong
#platform=1.0.0

platform=$1
version=$2
YIWAN="gintama-ucloud-demo"
set -x

function update_code () {
    prod_svn_dir=/data/svn/prod/$platform/$version/
    svn up $prod_svn_dir
    sudo rsync -avz    --exclude "config/" --exclude ".svn" --exclude "data/"   $prod_svn_dir/game_code    $YIWAN::$platform
    sudo rsync -avz  $prod_svn_dir/game_code/config/$platform/rand_name.php           $prod_svn_dir/game_code/config/$platform/sensitive_words.php    $YIWAN::$platform/game_code/config/$platform/

                        }

if [ "$platform" != "" -a "$version" != "" ];then
   update_code
else
   echo -e "\e[105mPlatform name and version should be given\e[0m"
   echo -e "\e[105mUsage: $0 jidong 1.0.0\e[0m"
fi
