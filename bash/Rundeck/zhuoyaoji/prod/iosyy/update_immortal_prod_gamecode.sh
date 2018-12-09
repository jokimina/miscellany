#platform=jidong
#platform=1.0.0

platform=$1
version=$2
YIWAN="immortal-jidong-demo"
#set -x

function update_code () {
    prod_svn_dir=/data/svn/prod/$platform/$version/
    svn up $prod_svn_dir
    sudo rsync -avz    --exclude "conf/" --exclude "xls/" --exclude ".svn" --exclude "logs/"  --exclude "vendor/"  --exclude "dev/" --exclude "local/" --exclude "qa/" --exclude "index.php" $prod_svn_dir/    $YIWAN::$platform/$version/
    #sudo rsync -avz  --delete /tmp/hotupdate/  $YIWAN::$platform/$version/hotupdate/

    #热资源生成区服
#    sudo rsync -avz    /tmp/server_list.txt    $YIWAN::$platform/$version/server_list.txt 
    #sudo rsync -avz  $prod_svn_dir/game_code/config/$platform/rand_name.php           $prod_svn_dir/game_code/config/$platform/sensitive_words.php    $YIWAN::$platform/game_code/config/$platform/

                        }

if [ "$platform" != "" -a "$version" != "" ];then
   update_code
else
   echo -e "\e[105mPlatform name and version should be given\e[0m"
   echo -e "\e[105mUsage: $0 jidong 1.0.0\e[0m"
fi
