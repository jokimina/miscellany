#!/bin/bash
#merge qa svn code to prod svn code
#define variables
platform=yn
version=1.8.0
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

#merge qa svn branch to prod svn working directory 
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

#rsync -avz --exclude ".svn" $qa_svn_dir/$platform/$version/   $prod_svn_dir/$platform/$version/

rsync -avz --exclude ".svn" --delete  $qa_svn_dir/$platform/$version/   $prod_svn_dir/$platform/$version/  >> /tmp/$platform_$version_svn_delete.txt

extra_dirs=$(cat /tmp/$platform_$version_svn_delete.txt|grep "non-empty directory:"|awk '{print $5}')

for dir in $(echo $extra_dirs)
do
    echo "deleting  $dir    from $prod_svn_dir/$platform/$version"
    rm -rf $prod_svn_dir/$platform/$version/$dir

done



rm -rf /tmp/$platform_$version_svn_delete.txt







