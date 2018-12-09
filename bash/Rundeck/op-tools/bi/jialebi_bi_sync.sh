#!/bin/bash
#同步加勒比线上Bi代码
#set -x
sync_type=$1
is_run=$2
src_bi_code="/data/jialebi_app/bi_analyzer/"
src_cps_code="/data/jialebi_app/jlbcps/"


function bi(){
	svn up $src_bi_code
	rsync -rlvzD --exclude "third_party/"  --exclude ".htaccess" --exclude "cache/" --exclude "config" --exclude "runtime" --exclude ".svn" $comment  $src_bi_code 60.191.203.62::jlb_bi
}


function cps(){
	svn up $src_cps_code
	rsync -rlvzD --exclude "config/" --exclude ".tags"  --exclude "common.php"  --exclude "runtime" --exclude "main.php" --exclude ".svn" --exclude "runtime"  $comment $src_cps_code 60.191.203.62::jlb_cps
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
