platform=$1
version=$2
YIWAN="gintama-ucloud-demo"

function update_code () {
    prod_svn_dir=/data/svn/prod/$platform/$version/
    svn up $prod_svn_dir
    sudo rsync -avz    --exclude "config/" --exclude ".svn" --exclude "data/"   $prod_svn_dir/game_code    $YIWAN::$platform

                        }

if [ "$platform" != "" -a "$version" != "" ];then
   update_code
else
   echo -e "\e[105mPlatform name and version should be given\e[0m"
   echo -e "\e[105mUsage: $0 qagintama 1.0.0\e[0m"
fi
