#!/bin/bash

#define variables
platform=esa
version=1.8.0
dev_svn_base=https://svn.jidongnet.com/svn/zhanguo/dev/server/branch
qa_svn_base=https://svn.jidongnet.com/svn/zhanguo/qa/server
qa_svn_dir=/data/svn

#svn up and merge code from dev branch to qa svn checkout directory
svn list $qa_svn_base/$platform/$version
if [ $? -ne 0 ];then
   echo "qa_svn_base/$platform/$version not exists"
   svn cp $dev_svn_base/$platform/$version $qa_svn_base/$platform/$version   --parents -m "create $platform/$version on qa svn"
fi
if [ ! -d "$qa_svn_dir/$platform/$version" ];then
   echo "$qa_svn_dir/$platform/$version not exists"
   svn co $qa_svn_base/$platform/$version   $qa_svn_dir/$platform/$version
else
   svn up $qa_svn_dir/$platform/$version
fi


#merge code from dev svn branche to qa svn working  directory
cd $qa_svn_dir/$platform/$version

string=$1
echo  "******************THE GIVEN REVISION STRING IS  $string********************"
num=$(echo "$string" | awk -F"," '{print NF}')

for i in $(seq 1 $num)
do
            string_sub=$( echo "$string" | awk -F"," "{ print \$$i }")
            num2=$(echo "$string_sub" | awk -F":" '{print NF}')
            if [ $num2 -ge 2 ];then
               svn merge $dev_svn_base/$platform/$version -r $string_sub
            else
               svn merge $dev_svn_base/$platform/$version -c $string_sub
            fi
done








