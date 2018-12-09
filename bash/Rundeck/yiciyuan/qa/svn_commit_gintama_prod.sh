#!/bin/bash
#commit prod svn after test ok
platform=$1
prod_message=$2

version=$3

#
prod_svn_dir=/data/svn/prod/$platform/$version

function commit_prod_svn () {

	#chekc qa_svn_dir svn status
	svn status $prod_svn_dir
	
	#svn add    $(svn status $prod_svn_dir|awk '$1=="?"{print $2}'|grep -v  -E ".tmp$|.db$")
	add_files=$(svn status $prod_svn_dir|awk '$1=="?"{print $2}'|grep -v  -E ".tmp$|.db$")
	
	if [ "$add_files" == "" ];then
	   echo "**************No files need to add into $prod_svn_dir***********"
	else
	   svn add $add_files
	fi
	
	delete_files=$(svn status $prod_svn_dir|awk '$1=="!"{print $2}')
	echo $delete_files
	if [ "$delete_files" == "" ];then
	   echo "**************No files need to delete in $prod_svn_dir***********"
	else
	   svn rm  --force   $delete_files
	fi
	
	
	
	#commit 
	echo "**********THE prod message is $prod_message***************"
	svn cleanup $prod_svn_dir
	svn commit $prod_svn_dir -m "$prod_message"

         }
if [ "$platform" != ""  -a "$version" != ""   ];then
   commit_prod_svn
else
   echo -e "\e[105mPlatform name should be given\e[0m"
   echo -e "\e[105mUsage: $0 qagintama test 1.0.0\e[0m"
fi
