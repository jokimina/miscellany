#!/bin/bash

#define variables
platform=$1
revision_tag=$2

version_tag=$(echo $revision_tag|awk -F"." '{print $1"."$2"."$3}')
version=$3

if [ "$version" != "$version_tag" ];then
   version=$version_tag
fi
function merge_code () {
	dev_svn_base=https://svn.jidongnet.com/svn/GINTAMA/dev/server/tag/
	qa_svn_base=https://svn.jidongnet.com/svn/GINTAMA/qa/server/tag/
	qa_svn_dir=/data/svn/qa/
	dev_svn_dir=/data/svn/dev/
	
	#svn up and merge code from dev branch to qa svn checkout directory
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
  	
        rm -rf $dev_svn_dir/$platform/$version	
	svn export $dev_svn_base/$platform/$revision_tag   $dev_svn_dir/$platform/$version   --force
	
	rsync -avz  --exclude ".svn" $dev_svn_dir/$platform/$version/  $qa_svn_dir/$platform/$version

                       }

if [ "$platform" != "" -a "$revision_tag" != "" ];then
   merge_code
else
   echo -e "\e[105mBoth platform name and revison string should be given\e[0m"
   echo -e "\e[105mUsage: $0 qagintama  1.0.0.2\e[0m"
fi





#
##merge code from dev svn branche to qa svn working  directory
#cd $qa_svn_dir/$platform/$version
#
#string=$1
#echo  "******************THE GIVEN REVISION STRING IS  $string********************"
#num=$(echo "$string" | awk -F"," '{print NF}')
#
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
#
#
#
#
#
#
#
#
