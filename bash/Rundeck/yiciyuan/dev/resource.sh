#!/bin/bash
#生成项目三资源

#svn 账户密码
svnUser="chenwh"
svnPassword="183678"

#debug
#set -x

#平台  
platform=$1
#大版本
version=$2
#是否生成对应资源 默认为 "no"
buildImg=$3
buildLua=$4
buildXls=$5

IsTest=$(echo $@ | awk '{print $NF}')
if [ "$IsTest" == "test" ];then
	VersionPath="/data/gintama/dev_default/hot_resource/$platform/$version/filelist"
	echo "############## Current version under path : $VersionPath  ###################"
	find $VersionPath -name "*.php"  | grep -Po '\d+(?=\.php)' | sort -n | awk '{ORS=" ";$1=$1}1'
	echo ""
	echo "###########################################################################################################################"
	exit 0
fi


if [ "$buildImg" == "no" -a "$buildLua" == "no" -a "$buildXls" == "no" ];then
	echo "no resource type  thing you selected ! "
	echo "what you want to do ? "
	exit 1
fi

[ $buildImg == "yes" ] && buildImg=1
[ $buildLua == "yes" ] && buildLua=1
[ $buildXls == "yes" ] && buildXls=1



#########    路径设置   ##############
export_dir="/data/gintama/dev_default/hot_resource/"
game_dir="/data/gintama/dev_default/branch_$version/" 
hot_version_file="/data/gintama/dev_default/branch_${version}/config/${platform}/version.ini"

#资源分branch 生成   重要！！！打新分支后 要处理
if [ $platform != "dev" ];then
	svnUrlPer="${platform}_${version}_branch"
else
	svnUrlPer="trunk"
	game_dir="/data/gintama/dev_default/game_server/"
	hot_version_file="/data/gintama/dev_default/game_server/config/$platform/version.ini"
fi

######## 获取base_version   ############

chmod 777 $hot_version_file
old_base_version=$(awk  '/base_version/{print $3}' $hot_version_file)
old_hot_version=$(awk  '/hot_version/{print $3}' $hot_version_file)

echo "######################  base_version now is  $old_base_version !! ##############################"
####### base_version old_base_version 加一  ###########
base_version=$(expr $old_base_version + 1 )
#hotversion=$(expr $old_hot_version + 1 )
hotversion=$base_version

echo "###################### file : $hot_version_file ####################################"
echo "###################### update base_version to $base_version ################################"
sed -i '/base_version/s/'$old_base_version'/'$base_version'/g'  $hot_version_file

#svn xls目录
svnUrlXls="https://svn.jidongnet.com/svn/GINTAMA/dev/design/"${svnUrlPer}"/xls/"
svnUrlLua="https://svn.jidongnet.com/svn/GINTAMA/dev/design/"${svnUrlPer}"/formula/"
svnUrlImg="https://svn.jidongnet.com/svn/GINTAMA/dev/design/"${svnUrlPer}"/download/"
svnFileName=(animates images particles config background sounds zh-Hans ui)

#导出目录
exportDir=$export_dir
##todo
exportDirNew=${exportDir}${platform}/${version}/new/
exportDirFileList=${exportDir}${platform}/${version}/filelist/

##最新备份目录
exportDirMain=${exportDir}${platform}/${version}/${hotversion}/

#xls导出目录
gameDir=$game_dir
xmlDir=${gameDir}"/xls/out_list/"${platform}/
#游戏脚本目录 php
phpDir=${gameDir}"/tools/gen_data_1.php"
#遍历文件
phpFileList=${gameDir}"/tools/filelist.php"
#差异包
phpDiffFile=${gameDir}"/tools/filediff.php"
#生成json目录
jsonUrl=${gameDir}"/public/resource/"${platform}/

#================参数准备完成===========================

#================生成LUA===============================
if [[ "${buildLua}" -eq "1" ]]; then
	rm -rf ${exportDirNew}formula
	echo "t\nt\n" | svn --username ${svnUser} --password ${svnPassword} --force export -q ${svnUrlLua} ${exportDirNew}formula
	echo "t\nt\n" | svn --username ${svnUser} --password ${svnPassword} --force export -q ${svnUrlLua} ${gameDir}/data/${platform}/formula
	echo "<br/>parse LUA sucess!!<br/>"
fi

#================解析xls===============================
if [[ "${buildXls}" -eq "1" ]]; then
	mkdir -p ${xmlDir}
	echo "t\nt\n" | svn --username ${svnUser} --password ${svnPassword} --force export -q ${svnUrlXls} ${exportDirNew}xls
	cp -rf ${exportDirNew}xls/* ${xmlDir}
	rm -rf ${exportDirNew}xls

	mkdir -p ${jsonUrl}json/

	result=$(/usr/bin/php ${phpDir} ${platform})
	if [[ "$result" -eq "ok" ]]; then
		echo "ok"
	else
		echo "ERROR: $result" 
		exit 111
	fi
	mkdir -p ${exportDirNew}json

	cp -rf ${jsonUrl}json/* ${exportDirNew}json
	#mkdir -p ${exportDirNew}10000
	#cp -rf ${jsonUrl}10000/* ${exportDirNew}10000
	echo "parse xls sucess !!"
fi

#================生成IMG===============================
if [[ "${buildImg}" -eq "1" ]]; then
	echo "parse IMG start!"
	for data in ${svnFileName[@]}  
	do  
	    echo ${data}  
	    echo "t\nt\n" | svn --username ${svnUser} --password ${svnPassword} --force export -q ${svnUrlImg}${data} ${exportDirNew}${data}
	done
	echo "gen IMG end !!"
fi	

#================遍历文件取MD5 写入文件列表===============
mkdir -p ${exportDirFileList}
/usr/bin/php ${phpFileList} ${exportDirNew} ${exportDirFileList}${hotversion}.php
echo "foreach file's MD5, write to file list!"
#================打一份最新的包=========================

mkdir -p ${exportDirMain}${hotversion}/

cd ${exportDirNew}
#cp  -f ${exportDirMain}check_file.json ./
echo "###########  zip : ${exportDirMain}${hotversion}/download.zip  ###########"
zip -rq ${exportDirMain}${hotversion}/download.zip ./*     
#rm -f check_file.json
echo "take a new package!"

#================生成差异包============================
/usr/bin/php ${phpDiffFile} ${exportDirMain} ${exportDir}${platform}/${version}/ ${hotversion}
echo "gen diff package!!!"

old_checksum_file="/data/gintama/dev_default/hot_resource/$platform/$version/filelist/$old_base_version.php"
new_checksum_file="/data/gintama/dev_default/hot_resource/$platform/$version/filelist/$base_version.php"

echo '------------------------------------------------------------------------------------------------------'

if diff $old_checksum_file $new_checksum_file &> /dev/null ;then
	echo "no change between $base_version and $old_base_version!!!!!"
else
	echo "xxxxxxxxxxxxxxxxxxxxxxxxxxx  diff list xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	diff $old_checksum_file $new_checksum_file
	echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
fi
exit

