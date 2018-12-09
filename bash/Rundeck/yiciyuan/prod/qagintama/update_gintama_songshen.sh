platform=$1
version=$2
YIWAN="gintama-ucloud-demo"

function update_code () {
    prod_svn_dir=/data/svn/prod/$platform/$version/
    cdn_dir=/data/cdn_data/resource/$platform/$version/
    qa_gamecode_dir=/data/gintama_app/${platform}_new/game_code/
    hot_version=$(grep service.hot_version $qa_gamecode_dir/config/$platform/config.ini|awk '{print $3}'|uniq)
    svn up $prod_svn_dir
    sudo rsync -avz    --exclude "config/" --exclude ".svn"  $prod_svn_dir/game_code    $YIWAN::${platform}_songshen
    sudo rsync -avz    --exclude ".svn" $cdn_dir/$hot_version $YIWAN::${platform}_songshen_cdn

                        }

if [ "$platform" != "" -a "$version" != "" ];then
   update_code
else
   echo -e "\e[105mPlatform name and version should be given\e[0m"
   echo -e "\e[105mUsage: $0 qagintama 1.0.0\e[0m"
fi
