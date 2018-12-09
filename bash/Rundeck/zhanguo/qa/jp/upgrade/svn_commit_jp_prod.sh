#!/bin/bash
#commit qa svn after test ok
platform=jp
version=1.7.0
prod_svn_dir=/svn/$platform/$version

#chekc qa_svn_dir svn status
svn status $prod_svn_dir

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
prod_message=$1
echo "**********THE prod message is $prod_message***************"
svn commit $prod_svn_dir -m "$prod_message"
