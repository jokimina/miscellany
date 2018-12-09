#!/bin/bash
#用来同步官网代码

action=$1


function init() {
SERVER_LIST=( "115.239.196.113" )

WEB_PATH="/data/www.jidongnet.com/"
svn up $WEB_PATH 
echo "update svn version ....."

}

#发布SVN上最新版本到线上的WEB服务器
function  sync_test() {
	cd $WEB_PATH

	new_static_files=$(svn status |awk '/^(?|M)/{print $2}')
	if [ -z $new_static_files ];then
		echo "##########################   no new file to update !!!!!!!!!! #################################"	
		echo "##########################   check you dede CMS operation !!!!!!!!!! #################################"	
		exit 127
	else
		for file in "$new_static_files"
		do 
			echo "############################# add new static files ##########################"	
			svn add $file
		done
		svn ci -m 'commit new static files.'
	fi

	echo "#############################  sync start ####################################"
	for server in ${SERVER_LIST[@]}
	do
		echo "#######################  [ $server ] start  ...   #########################"	
		rsync $comment -rltvzD --exclude "dede/" --exclude "common.inc.php"  --exclude ".svn" --exclude "*.log"  --exclude ".tags" --exclude ".DS_Store"  $WEB_PATH $server::www.jidongnet.com
	done
}

function sync_run() {
	echo "#############################   start rsync to www.jidongnet.com !   ########################"
	demo_path="/data/jidongweb/web.jidongnet.com/"
	online_path="/data/jidongweb/www.jidongnet.com/"
	ssh -t root@115.239.196.113 "rsync -avz --exclude "dede/" $demo_path $online_path"
}

#回滚一个版本
function rollback() {
	tmp_file="/tmp/tmp_svn.log"
	svn_tmp_log=$(svn log $WEB_PATH > $tmp_file)
	now_reversion=$(svn info $WEB_PATH | grep -Po '(?<=Last Changed Rev: )\d+')
	last_reversion=$(grep -Po -m 2 '(?<=r)\d+(?=\s+|)' $tmp_file | tail -n1 )
	echo -e  "###############  svn log : \n `cat $tmp_file`"

	echo "######################## now reversion is $now_reversion   #########################"
	echo "######################## will rollback to  $last_reversion   #########################"
	cd $WEB_PATH
	svn merge -r $now_reversion:$last_reversion  .
	svn ci  --force-log -m "WEB版本回滚至: $last_reversion"
	#同步
	sync
}

case $action in 
	test)
		#comment="--dry-run"
		comment=""
		init
		sync_test
	;;
	run)
		init
		sync_run
	;;
	rollback)
		rollback
	;;
	*)
		echo "usage : sh $0 (run|test|rollback) "
	;;
esac


