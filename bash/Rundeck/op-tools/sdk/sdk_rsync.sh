#!/bin/bash
#用来同步SDK代码

action=$1
platform=$2



#需要同步的SDK服务器列表
if [ "$platform" == "jidong" ];then
	SERVER_LIST=( "123.59.62.161" "123.59.66.75" )
elif [ "$platform" == "japan" ];then
	SERVER_LIST=( "52.68.205.240" "52.68.30.20" )
fi
	


SDK_PATH="/data/sdk/jdsdk/"
svn up $SDK_PATH 

#发布SVN上最新版本到线上的SDK服务器
function  sync() {
	echo "update svn version ....."
	if [ $action == "test" ];then	
		if  find /data/sdk/jdsdk/sdk.youxi021.com/protected/ -name "*.php" -exec php -l {} \; | grep "Parse error" -A 1 ;then 
			echo "!!!!!!!!!!!!!!!!!!!!! warnning !!!!!!!!!!!!!!!!!!!!!!!!"
			echo "there syntax error...... check your code !!!!!!"
			exit 127	
		fi
	fi
	echo "#############################  sync start ####################################"
	for server in ${SERVER_LIST[@]}
	do
		echo "#######################  [ $server ] start  ...   #########################"	
		rsync $comment -rltvzD --exclude "console.php" --exclude "main.php" --exclude "runtime" --exclude ".svn" --exclude "*.log"  --exclude ".tags" --exclude ".DS_Store"  $SDK_PATH $server::sdk
	done
}

#回滚一个版本
function rollback() {
	tmp_file="/tmp/tmp_svn.log"
	svn_tmp_log=$(svn log $SDK_PATH > $tmp_file)
	now_reversion=$(svn info $SDK_PATH | grep -Po '(?<=Last Changed Rev: )\d+')
	last_reversion=$(grep -Po -m 2 '(?<=r)\d+(?=\s+|)' $tmp_file | tail -n1 )
	echo -e  "###############  svn log : \n `cat $tmp_file`"

	echo "######################## now reversion is $now_reversion   #########################"
	echo "######################## will rollback to  $last_reversion   #########################"
	cd $SDK_PATH
	svn merge -r $now_reversion:$last_reversion  .
	svn ci  --force-log -m "SDK版本回滚至: $last_reversion"
	#同步
	sync
}

case $action in 
	test)
		comment="--dry-run"
		sync
	;;
	run)
		comment=""
		sync
	;;
	rollback)
		rollback
	;;
esac

