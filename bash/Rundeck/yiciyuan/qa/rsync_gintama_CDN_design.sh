#!/bin/bash
platform=$1
position=$2
set -x
design_dir="/data/cdn_data/resource/$platform/design"

function get_design(){

     svn rm --force  https://svn.jidongnet.com/svn/GINTAMA/$d/hot_resource/tag/$platform/ -m "删除老design"
     #复制dev design资源
if [ "$position" == "qa" ];then
     svn cp --parents   https://svn.jidongnet.com/svn/GINTAMA/dev/design/${platform}_design/   https://svn.jidongnet.com/svn/GINTAMA/$d/hot_resource/tag/$platform/ -m "复制dev design资源"
fi

    svn export --force https://svn.jidongnet.com/svn/GINTAMA/qa/hot_resource/tag/$platform/    $design_dir/
#if [ -d "$design_dir" ];then
#    svn update $design_dir
#    echo "ok!"
#else
#    svn co https://svn.jidongnet.com/svn/GINTAMA/qa/hot_resource/tag/${platform}/ $design_dir
#fi
}
function up_design(){
	if [ "$platform" == "jidong" ];then
		#上传到线上CDN目录
		/bin/sh	/data/tools/prod/baidu/update_gintama_prod_CDN.sh $platform design
	else
		#上传到线上CDN目录
		/bin/sh	/data/tools/prod/$platform/update_gintama_prod_CDN.sh $platform design
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
	rsync -avz --exclude ".svn" $design_dir/ $songshen_cdn::${platform}_songshen_cdn/design/	
}

if [ "$position" == "qa" ];then
	s="dev"
	d="qa"
	get_design
elif [ "$position" == "prod" ];then
	s="qa"
	d="prod"
	get_design
	up_design
elif [ "$position" == "songshen" ];then
	up_songshen
fi
