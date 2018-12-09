platform=$1
version=$2

CDN="zg-jidong02-web"
YIWAN="gintama-ucloud-demo"


function update_cdn () {
cdndir=/data/cdn_data/resource/$platform/$version/
prod_svn_dir=/data/svn/prod/$platform/$version
qa_gamecode_dir=/data/gintama_app/$platform/game_code/
hot_file=cdn/hot_version.txt
hot_file_version_old=$(awk -F":" '/hot_version/{print $2}' cdn/hot_version.txt)
hot_file_version_new=$(grep service.hot_version $qa_gamecode_dir/config/$platform/config.ini|awk '{print $3}'|uniq)
hot_version_dir=$version/$hot_file_version_new


echo -e  "\e[33mThe old version is $hot_file_version_old\e[0m"
echo -e "\e[33mThe new version will be updated from $hot_file_version_old to $hot_file_version_new\e[0m"
sudo   sed -i "/hot_version/s/$hot_file_version_old/$hot_file_version_new/" $hot_file
cat $hot_file
cp  $hot_file $prod_svn_dir/game_code/
rsync -avz  $hot_file    $YIWAN::$platform/game_code/


sudo rsync -avz  --exclude ".svn" $prod_svn_dir/game_code/data    $YIWAN::$platform/game_code/

sudo rsync -avz $cdndir/*  --exclude ".svn"    cdn/$version
sudo rsync -avz cdn/$hot_version_dir  $CDN::gintamacdn/$platform/$version

                       }

if [ "$platform" != "" -a "$version" != "" ];then 
   update_cdn
else
   echo -e "\e[105mPlatform name and version should be given\e[0m"
   echo -e "\e[105mUsage: $0 qagintama  1.0.0\e[0m"
fi
 
