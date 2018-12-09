#!/bin/bash
Platform=$1			#dev
BigVersion=$2		#0.1.2
HotVersion=$3		#16

Platform=$(echo $Platform | tr -d [0-9])


function dev_tag () {

	#=========路径准备========
	#####核心数组#####
	# platform_dev_game_route=game_server
	# platform_dev_online=qagintama
	# platform_dev_game_svn=trunk

	game_route="branch_${BigVersion}"
 	online="${Platform}"
	game_svn="branch_${BigVersion}/"


	################
	#
	#热资源路径
	HotResource=/data/gintama/dev_default/hot_resource
	#代码路径
	GameResource=/data/gintama/dev_default/${game_route} 

	#svn地址
	SvnHotResource=https://svn.jidongnet.com/svn/GINTAMA/dev/hot_resource/
	SvnServer=https://svn.jidongnet.com/svn/GINTAMA/dev/server/
	#========================


	#1.删除指定平台下的热资源
	rm -rf $HotResource/$online/$BigVersion/*
	svn up $HotResource/$online/$BigVersion/ -q

	rm -rf ${GameResource}/data/$online/*
	svn up ${GameResource}/data/$online -q

	#2.生成资源
	#版本、平台
	export version=$BigVersion
	export hot_version=$HotVersion
	export platform=$online

	#生成条件
	export build_lua=1
	export build_xls=1
	export build_img=1
	export export_dir=${HotResource}/
	export game_dir=${GameResource}

	echo ${SvnHotResource}tag/${online} 
	sh ${GameResource}/tools/resource.sh 

	#提交资源
	svn add ${export_dir}${online}/${BigVersion} --non-recursive --force
	svn add ${export_dir}${online}/${BigVersion}/${HotVersion} --force
	svn add ${export_dir}${online}/${BigVersion}/filelist --force
	svn ci  ${export_dir}${online}/${BigVersion} -m "tag ${online}${BigVersion}${HotVersion}"

	##svn cp ${export_dir}${Platform}/${BigVersion}/${HotVersion} ${SvnHotResource}trunk/${Platform}/$BigVersion/${HotVersion} --parents -q -m "add"
	##svn cp ${export_dir}${Platform}/${BigVersion}/filelist ${SvnHotResource}trunk/${Platform}/$BigVersion/filelist --parents -q -m "add"

	svn add ${GameResource}/data/${online}/* --force
	svn ci ${GameResource}/data/${online} -m "tag ${online}${BigVersion}${HotVersion}"

	echo "game code ok"

	#打tag  todo qagintama
	svn del ${SvnHotResource}tag/${online}/${BigVersion}.${HotVersion} -m"tag ${BigVersion}.${HotVersion}" --force -q
	svn cp ${SvnHotResource}trunk/${online}/${BigVersion}/${HotVersion}/ ${SvnHotResource}tag/${online}/${BigVersion}.${HotVersion}/ --parents -q -m "tag ${BigVersion}.${HotVersion}" 
	echo "hot resource tag ok"																								 

	svn del ${SvnServer}tag/${online}/${BigVersion}.${HotVersion} -m"tag ${BigVersion}.${HotVersion}" --force -q
	svn mkdir ${SvnServer}tag/${online}/${BigVersion}.${HotVersion}/ -m"tag ${BigVersion}.${HotVersion}"
	svn cp ${SvnServer}${game_svn} ${SvnServer}tag/${online}/${BigVersion}.${HotVersion}/game_code -m"tag ${BigVersion}.${HotVersion}"
	echo "game code tag ok"

	#更改资源号 版本号
	service_hot_version_old=$(grep hot_version ${game_dir}/config/${online}/version.ini|awk '{print $3}')
	#game_hot_version_old=$(grep service.hot_version ${game_dir}/config/${online}/config.ini#|awk '{print $3}'|uniq)
	#-e "/game.hot_version/s/$game_hot_version_old/$tag/g" 
	sed  -i -e  "/hot_version/s/$service_hot_version_old/$HotVersion/g"   ${game_dir}/config/${online}/version.ini

	#重启php
	service php-fpm reload
	chmod -R 777 $HotResource/$online/$BigVersion
	chmod -R 777 ${GameResource}/data
}



#Platform=$1			#dev
#BigVersion=$2		#0.1.2
#HotVersion=$3		#16
#check_platform = (dev )

if [ "$Platform" != ""  -a  "$BigVersion"  != "" -a "$HotVersion" != "" ];then
	dev_tag
else
	echo "wrong arguement"
fi 



