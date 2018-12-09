#!/bin/bash
#commit qa svn after test ok
platform=tencent
version=1.7.0
prod_svn_dir=/svn/$platform/$version

#chekc qa_svn_dir svn status
svn status $prod_svn_dir


#commit 
prod_message=$1
echo "**********THE prod message is $prod_message***************"
svn commit $prod_svn_dir -m "$prod_message"
