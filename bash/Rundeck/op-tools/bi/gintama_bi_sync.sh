#!/bin/bash
#同步亿次元线上Bi代码
#set -x
sync_type=$1
is_run=$2
src_bi_code="/data/gintama_app/bi_code/"
src_cps_code="/data/gintama_app/ycycps/"


function bi(){
	svn up $src_bi_code
	rsync -rltvzD --exclude "config" --exclude "runtime" --exclude ".svn" $comment  $src_bi_code 115.231.94.215::bi
}


function cps(){
	svn up $src_cps_code
	rsync -rltvzD --exclude "config" --exclude "common.php" --exclude "config" --exclude "runtime" --exclude "main.php" --exclude ".svn" --exclude "runtime"  $comment $src_cps_code 115.231.94.215::cps
}


if [ $is_run == "test" ];then
	comment="--dry-run"
elif [ $is_run == "run" ];then
	comment=""
fi

case $sync_type in 
	bi)
	   bi
	;;
	cps)
	  cps
	;;
esac
