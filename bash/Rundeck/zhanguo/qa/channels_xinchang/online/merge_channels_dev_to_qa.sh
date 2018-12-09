#!/bin/bash

#define variables
revision_tag=$1
platform=xinchang
version=1.2.0
dev_svn_base=https://svn.jidongnet.com/svn/zhanguo/dev/server/tag
qa_svn_base=https://svn.jidongnet.com/svn/zhanguo/qa/server
qa_svn_dir=/data/svn
dev_svn_dir=/data/dev_svn

#svn up and merge code from dev branch to qa svn checkout directory

function merge_code () {

svn list $qa_svn_base/$platform/$version
if [ $? -ne 0 ];then
   echo "qa_svn_base/$platform/$version not exists"
   svn cp $dev_svn_base/$platform/$revision_tag $qa_svn_base/$platform/$version   --parents -m "create $platform/$version on qa svn"
fi
if [ ! -d "$qa_svn_dir/$platform/$version" ];then
   echo "$qa_svn_dir/$platform/$version not exists"
   svn co $qa_svn_base/$platform/$version   $qa_svn_dir/$platform/$version
else
   svn up $qa_svn_dir/$platform/$version
fi

svn export $dev_svn_base/$platform/$revision_tag   $dev_svn_dir/$platform/$version   --force
rsync -avz  --exclude ".svn" --exclude "config/app.conf.php" --exclude "htdoc/resource/"  --exclude "data/" --exclude "xml/out_list/"  $dev_svn_dir/$platform/$version/  $qa_svn_dir/$platform/$version
rsync -avz   $dev_svn_dir/$platform/$version/game_server/data/autoload.php   $qa_svn_dir/$platform/$version/game_server/data/autoload.php 
    }

if [ "$revision_tag" != "" ];then
   merge_code
else
   echo -e "\e[105mrevison string should be given\e[0m"
   echo -e "\e[105mUsage: $0 1.1.0.1\e[0m"
fi

#rm -rf  $dev_svn_dir/$platform/$version 	



#merge code from dev svn branche to qa svn working  directory
#cd $qa_svn_dir/$platform/$version

#string=$1
#echo  "******************THE GIVEN REVISION STRING IS  $string********************"
#num=$(echo "$string" | awk -F"," '{print NF}')

#for i in $(seq 1 $num)
#do
#            string_sub=$( echo "$string" | awk -F"," "{ print \$$i }")
#            num2=$(echo "$string_sub" | awk -F":" '{print NF}')
#            if [ $num2 -ge 2 ];then
#               svn merge $dev_svn_base/$platform/$version -r $string_sub
#            else
#               svn merge $dev_svn_base/$platform/$version -c $string_sub
#            fi
#done








