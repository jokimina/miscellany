#!/bin/bash
platform=$1
position=$2
#set -x
sound_dir="/data/cdn_data/resource/$platform/sound"

function get_sound(){

     svn rm --force  https://svn.jidongnet.com/svn/GINTAMA/$d/hot_resource/tag/$platform/ -m "删除老sound"
     #复制dev sound资源
if [ "$position" == "qa" ];then
     svn cp --parents   https://svn.jidongnet.com/svn/GINTAMA/dev/design/${platform}_sound/   https://svn.jidongnet.com/svn/GINTAMA/$d/hot_resource/tag/$platform/ -m "复制dev sound资源"
fi

    svn export --force https://svn.jidongnet.com/svn/GINTAMA/qa/hot_resource/tag/$platform/    $sound_dir/
#if [ -d "$sound_dir" ];then
#    svn update $sound_dir
#    echo "ok!"
#else
#    svn co https://svn.jidongnet.com/svn/GINTAMA/qa/hot_resource/tag/${platform}/ $sound_dir
#fi
}
function up_sound(){
	#上传到线上CDN目录
	if [ "$platform" == "baidu_jidong" ];then
		/bin/sh /data/tools/prod/baidu/update_gintama_prod_CDN.sh jidong sound
	else
		/bin/sh	/data/tools/prod/$platform/update_gintama_prod_CDN.sh $platform sound
	fi
}

function up_songshen(){
	if [ "$platform" == "quwan" ];then
		songshen_cdn="210.242.195.123"
	elif [ "$platform" == "japan" ];then
		songshen_cdn="52.68.147.132"
	elif [ "$platform" == "jidong" ];then
		songshen_cdn="180.76.158.6"
	else
	#Ucloud 平台
		songshen_cdn="122.226.199.109"
	fi
	#上传到送审CDN目录
	rsync -avz --progress --exclude ".svn" $sound_dir/ $songshen_cdn::${platform}_songshen_cdn/sound/	
}

if [ "$position" == "qa" ];then
	s="dev"
	d="qa"
	get_sound
elif [ "$position" == "prod" ];then
	s="qa"
	d="prod"
	get_sound
	up_sound
elif [ "$position" == "songshen" ];then
	up_songshen
fi
