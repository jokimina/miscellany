#!/bin/bash
#commit qa svn after test ok
platform=dream_ios
version=0.9.1
qa_svn_dir=/data/svn/qa/$platform/$version

#chekc qa_svn_dir svn status
svn status $qa_svn_dir

add_files=$(svn status $qa_svn_dir|awk '$1=="?"{print $2}'|grep -v  -E ".tmp$|.db$")

if [ "$add_files" == "" ];then
   echo "**************No files need to add into $qa_svn_dir***********"
else
   svn add $add_files
fi

#svn rm files
delete_files=$(svn status $qa_svn_dir|awk '$1=="!"{print $2}')
echo $delete_files
if [ "$delete_files" == "" ];then
   echo "**************No files need to delete in $qa_svn_dir***********"
else
   svn rm  --force   $delete_files
fi






qa_message=$1
echo "*********commit message is $qa_message************"
#qa_commit_file=/tmp/$platform_$version_qa_svn_commit$(date +%Y%m%d).txt
svn commit $qa_svn_dir -m "$qa_message"
#cat $qa_commit_file

