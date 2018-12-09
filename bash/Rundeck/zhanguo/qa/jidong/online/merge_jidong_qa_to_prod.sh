#!/bin/bash
#merge qa svn code to prod svn code
#define variables
platform=apple
version=2.1.0
prod_svn_base=https://svn.jidongnet.com/svn/zhanguo/prod/server
qa_svn_base=https://svn.jidongnet.com/svn/zhanguo/qa/server
prod_svn_dir=/svn
qa_svn_dir=/data/svn
#svn up and merge code from qa branch to prod svn checkout directory
svn list $prod_svn_base/$platform/$version
if [ $? -ne 0 ];then
   echo "$prod_svn_base/$platform/$version not exists"
   svn cp $qa_svn_base/$platform/$version $prod_svn_base/$platform/$version   --parents -m "create $platform/$version on prod svn"
fi
if [ ! -d "$prod_svn_dir/$platform/$version" ];then
   echo "$prod_svn_dir/$platform/$version not exists"
   svn co $prod_svn_base/$platform/$version   $prod_svn_dir/$platform/$version
else
   svn up $prod_svn_dir/$platform/$version
fi

#read -p "Please input the dev revision number:" revision
#echo "revision number is $revision"
#cd $prod_svn_dir/$platform/$version
#case
#svn merge $qa_svn_base/$platform/$version -r $revision

#merge design resources

#merge code from dev svn branche to qa svn working  directory
#cd $prod_svn_dir/$platform/$version

#string=$1
#echo  "******************THE GIVEN REVISION STRING IS  $string********************"
#num=$(echo "$string" | awk -F"," '{print NF}')

#for i in $(seq 1 $num)
#do
#            string_sub=$( echo "$string" | awk -F"," "{ print \$$i }")
#            num2=$(echo "$string_sub" | awk -F":" '{print NF}')
#            if [ $num2 -ge 2 ];then
#               svn merge $qa_svn_base/$platform/$version -r $string_sub
#            else
#               svn merge $qa_svn_base/$platform/$version -c $string_sub
#            fi
#done

rsync -avz --exclude ".svn" $qa_svn_dir/$platform/$version/   $prod_svn_dir/$platform/$version/






