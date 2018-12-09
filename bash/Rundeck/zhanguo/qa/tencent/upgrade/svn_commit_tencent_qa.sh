#!/bin/bash
#commit qa svn after test ok
platform=tencent
version=1.7.0
qa_svn_dir=/data/svn/$platform/$version

#chekc qa_svn_dir svn status
svn status $qa_svn_dir


#commit 
qa_message=$1
echo "*********commit message is $qa_message************"
#qa_commit_file=/tmp/$platform_$version_qa_svn_commit$(date +%Y%m%d).txt
svn commit $qa_svn_dir -m "$qa_message" 
#cat $qa_commit_file


