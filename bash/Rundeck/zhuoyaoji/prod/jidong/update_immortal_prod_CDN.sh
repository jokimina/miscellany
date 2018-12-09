#platform=jidong
#version=1.0.0
#/data/immortal_app/jidong/config/jidong/version.ini
#set -x
platform=$1
version=$2
CDN="zg-jidong02-web"
YIWAN="immortal-jidong-demo"

function update_cdn () {
cdndir=/data/cdn_data/resource/$platform/
prod_svn_dir=/data/svn/prod/$platform/
#qa_gamecode_dir=/data/immortal_app/$platform/
#hot_file=cdn/hot_version.txt
#hot_file_version_old=$(awk -F":" '/hot_version/{print $2}' cdn/hot_version.txt)
#hot_file_version_new=$(grep hot_version $qa_gamecode_dir/config/$platform/version.ini|awk '{print $3}'|uniq)
#hot_version_dir=$version/$hot_file_version_new


#echo -e  "\e[33mThe old version is $hot_file_version_old\e[0m"
#echo -e "\e[33mThe new version will be updated from $hot_file_version_old to $hot_file_version_new\e[0m"
#sudo   sed -i "/hot_version/s/$hot_file_version_old/$hot_file_version_new/" $hot_file
#cat $hot_file
#cp  $hot_file $prod_svn_dir/
#rsync -avz  $hot_file    $YIWAN::$platform/


#sudo rsync -avz  --exclude ".svn" $prod_svn_dir/data    $YIWAN::$platform/

[ ! -d /tmp/hotupdate/$platform/$version ] && mkdir -p /tmp/hotupdate/$platform/$version

sudo rsync -avz  --delete /tmp/hotupdate/$platform/$version/  $YIWAN::$platform/$version/hotupdate/


sudo rsync -avz $cdndir/  --exclude ".svn"    cdn/$platform/

#$CDN  /data/cdn_data/immortal/jidong/ 需要存在

sudo rsync --delete --progress -avz cdn/$platform/  $CDN::immortalcdn/$platform/
#sudo rsync -rvz -I cdn/$hot_version_dir  $CDN::immortalcdn/$platform/$version
}

function update_sound(){

sound_dir="/data/cdn_data/resource/$platform/"
cdn_dir="/data/tools/prod/$platform"

sudo rsync -avz $sound_dir/sound/ --exclude "[0-9].*[0-9]/" --exclude ".svn"    $cdn_dir/cdn/sound/

sudo rsync -avz --exclude ".svn" --exclude "[0-9].*[0-9]/" $cdn_dir/cdn/sound/  $CDN::immortalcdn/$platform/sound/

}

if [ "$platform" != "" -a "$version" != "" ];then
        if [ "$version" == "sound" ];then
                update_sound
        else
                update_cdn
        fi
else
   echo -e "\e[105mPlatform name and version should be given\e[0m"
   echo -e "\e[105mUsage: $0 jidong  1.0.0\e[0m"
fi

                               
