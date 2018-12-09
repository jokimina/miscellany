#!/bin/bash
#commit prod svn after test ok
platform=apple
version=1.9.0
prod_svn_dir=/svn/$platform/$version

#chekc qa_svn_dir svn status
svn status $prod_svn_dir

#svn add    $(svn status $prod_svn_dir|awk '$1=="?"{print $2}'|grep -v  -E ".tmp$|.db$")
add_files=$(svn status $prod_svn_dir|awk '$1=="?"{print $2}'|grep -v  -E ".tmp$|.db$")

if [ "$add_files" == "" ];then
   echo "**************No files need to add into $prod_svn_dir***********"
else
   svn add $add_files
fi
#commit 
prod_message=$1
echo "**********THE prod message is $prod_message***************"
svn commit $prod_svn_dir -m "$prod_message"
