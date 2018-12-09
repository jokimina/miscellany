#!/bin/bash
#commit qa svn after test ok
platform=apple
version=1.9.0
qa_svn_dir=/data/svn/$platform/$version

#chekc qa_svn_dir svn status
svn status $qa_svn_dir

add_files=$(svn status $qa_svn_dir|awk '$1=="?"{print $2}'|grep -v  -E ".tmp$|.db$")

if [ "$add_files" == "" ];then
   echo "**************No files need to add into $qa_svn_dir***********"
else
   svn add $add_files
fi
qa_message=$1
echo "*********commit message is $qa_message************"
#qa_commit_file=/tmp/$platform_$version_qa_svn_commit$(date +%Y%m%d).txt
svn commit $qa_svn_dir -m "$qa_message"
#cat $qa_commit_file
