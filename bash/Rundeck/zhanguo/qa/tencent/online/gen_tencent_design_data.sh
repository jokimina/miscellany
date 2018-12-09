#!/bin/bash
#generate design resource data from desgin svn branch

#define variables
platform=jp
version=1.3.0
design_svn_base=https://svn.jidongnet.com/svn/zhanguo/dev/design/branch
qa_svn_dir=/data/svn/$platform/$version

#load desgin data
sudo mkdir -p tmp_svn_data/{xml,php,resource}

sudo svn export --force   $design_svn_base/$platform/$version/xml   tmp_svn_data/xml
rsync -avz  tmp_svn_data/xml/   $qa_svn_dir/game_server/xml/out_list/   

sudo svn export --force   $design_svn_base/$platform/$version/php   tmp_svn_data/php
rsync -avz  tmp_svn_data/php/   $qa_svn_dir/game_server/data/formula/

sudo svn export --force   $design_svn_base/$platform/$version/resource   tmp_svn_data/resource
rsync -avz  tmp_svn_data/resource/   $qa_svn_dir/game_server/htdoc/resource/

sudo rm -rf tmp_svn_data
cp $qa_config_file /data/svn/$platform/$version/game_server/config/app.conf.php

#modify qa svn dir app.conf.php hot version and generate resource data

svn_config_file=$qa_svn_dir/game_server/config/app.conf.php
qa_config_file=/data/zhanguo_app/jp/zhanguo_server/config/app.conf.php

svn_hot_version_old=$(awk '/hot_version/{print $3}' $svn_config_file|awk -F"," '{print $1}')
qa_hot_version_old=$(awk '/hot_version/{print $3}' $qa_config_file|awk -F"," '{print $1}')

svn_hot_version_new=$(($qa_hot_version_old+1))
sed -i "/hot_version/s/$svn_hot_version_old/$svn_hot_version_new/" $svn_config_file

php /data/svn/$platform/$version/game_server/tools/gen_data.php 






