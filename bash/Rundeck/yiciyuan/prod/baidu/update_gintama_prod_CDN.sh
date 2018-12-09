#platform=jidong
#version=1.0.0
#/data/gintama_app/jidong/game_code/config/jidong/version.ini
set -x
platform=$1
version=$2
CDN="zg-jidong02-web"
YIWAN="gintama-baidu-demo"

function update_cdn () {
cdndir=/data/cdn_data/resource/$platform/$version/
prod_svn_dir=/data/svn/prod/$platform/$version
qa_gamecode_dir=/data/gintama_app/$platform/game_code/
hot_file=cdn/hot_version.txt
hot_file_version_old=$(awk -F":" '/hot_version/{print $2}' /data/tools/prod/baidu/cdn/hot_version.txt)
hot_file_version_new=$(grep hot_version $qa_gamecode_dir/config/$platform/version.ini|awk '{print $3}'|uniq)
hot_version_dir=$version/$hot_file_version_new


echo -e  "\e[33mThe old version is $hot_file_version_old\e[0m"
echo -e "\e[33mThe new version will be updated from $hot_file_version_old to $hot_file_version_new\e[0m"
sudo   sed -i "/hot_version/s/$hot_file_version_old/$hot_file_version_new/" $hot_file
cat $hot_file
cp  $hot_file $prod_svn_dir/game_code/
rsync -avz  $hot_file    $YIWAN::$platform/game_code/


sudo rsync -avz  --exclude ".svn" $prod_svn_dir/game_code/data    $YIWAN::$platform/game_code/
#同步 jidongadr资源到 cdn缓存目录  /data/tools/prod/baidu/baidu_cdn/jidongadr/1.0.6
sudo rsync -avz $cdndir/*  --exclude ".svn"    baidu_cdn/jidongadr/$version

#$CDN  /data/cdn_data/gintama/jidongadr/ 需要存在
##### 到Ucloud CDN #######
#echo "################ 到Ucloud CDN ###########################"
#sudo rsync -avz --dry-run cdn/$hot_version_dir  $CDN::gintama_baidu_cdn/$platform/$version
#sudo rsync -rvz --dry-run -I cdn/$hot_version_dir  $CDN::gintamacdn/$platform/$version

#### 到百度CDN #######
echo '################ 上传至百度CDN  ##########################'
CDN_ZIP="jidongadr_$version.zip"
cd /data/tools/prod/baidu/baidu_cdn
sudo zip -r -0 -v $CDN_ZIP  jidongadr/$hot_version_dir
sudo su -c "md5sum $CDN_ZIP > upload"
echo 'upload to baidu CDN .........'
lftp -p 8000 'yiciyuanzhanji:ycy!)0o0@180.76.141.26'  << eof
put $CDN_ZIP 
put upload
eof
echo 'done ....'
}

function update_sound(){

sound_dir="/data/cdn_data/resource/$platform/"

if [ $platform == "jidongadr" ];then
	sudo rsync -avz $sound_dir/sound/ --exclude "[0-9].*[0-9]/" --exclude ".svn"    /data/tools/prod/baidu/baidu_cdn/jidongadr/sound/

echo '################ 上传sound文件至百度CDN  ##########################'
CDN_ZIP="jidongadr_sound.zip"
cd /data/tools/prod/baidu/baidu_cdn
sudo zip -r -0 -v $CDN_ZIP  jidongadr/sound
sudo su -c "md5sum $CDN_ZIP > upload"
lftp -p 8000 'yiciyuanzhanji:ycy!)0o0@180.76.141.26'  << eof
put $CDN_ZIP
put upload
eof

else
    sudo rsync -avz $sound_dir/sound/ --exclude "[0-9].*[0-9]/" --exclude ".svn"    /data/tools/prod/baidu/baidu_cdn/jidong/sound/

echo '################ 上传sound文件至百度CDN  ##########################'
CDN_ZIP="jidong_sound.zip"
cd /data/tools/prod/baidu/baidu_cdn
sudo zip -r -0 -v $CDN_ZIP  jidong/sound
sudo su -c "md5sum $CDN_ZIP > upload"
lftp -p 8000 'yiciyuanzhanji:ycy!)0o0@180.76.141.26'  << eof
put $CDN_ZIP
put upload
eof

fi



#sudo rsync -avz --exclude ".svn" --exclude "[0-9].*[0-9]/" $cdn_dir/cdn/sound/  $CDN::gintama_baidu_cdn/$platform/sound/

}

function update_design(){

design_dir="/data/cdn_data/resource/$platform/"

if [ $platform == "jidongadr" ];then
	sudo rsync -avz $design_dir/design/ --exclude "[0-9].*[0-9]/" --exclude ".svn"    /data/tools/prod/baidu/baidu_cdn/jidongadr/design/

echo '################ 上传design文件至百度CDN  ##########################'
CDN_ZIP="jidongadr_design.zip"
cd /data/tools/prod/baidu/baidu_cdn
sudo zip -r -0 -v $CDN_ZIP  jidongadr/design
sudo su -c "md5sum $CDN_ZIP > upload"
lftp -p 8000 'yiciyuanzhanji:ycy!)0o0@180.76.141.26'  << eof
put $CDN_ZIP
put upload
eof

else
    sudo rsync -avz $design_dir/design/ --exclude "[0-9].*[0-9]/" --exclude ".svn"    /data/tools/prod/baidu/baidu_cdn/jidong/design/

echo '################ 上传design文件至百度CDN  ##########################'
CDN_ZIP="jidong_design.zip"
cd /data/tools/prod/baidu/baidu_cdn
sudo zip -r -0 -v $CDN_ZIP  jidong/design
sudo su -c "md5sum $CDN_ZIP > upload"
lftp -p 8000 'yiciyuanzhanji:ycy!)0o0@180.76.141.26'  << eof
put $CDN_ZIP
put upload
eof

fi

}


if [ "$platform" != "" -a "$version" != "" ];then
     if [ "$version" == "sound" ];then
                update_sound
        elif [ "$version" == "design" ];then
                update_design
        else
                update_cdn
        fi
else
   echo -e "\e[105mPlatform name and version should be given\e[0m"
   echo -e "\e[105mUsage: $0 jidong  1.0.0\e[0m"
fi

                               
