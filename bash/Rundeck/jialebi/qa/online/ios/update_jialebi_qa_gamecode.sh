#!/bin/bash
platform=dream_ios
version=0.9.1
qa_gamecode_dir=/data/jialebi_app/$platform/game_server
qa_svn_gamecode_dir=/data/svn/qa/$platform/$version/game_server/
qa_svn_pubcode_dir=/data/svn/qa/$platform/$version/game_public/

rsync -avz --exclude=".svn" --exclude="config/" --exclude="www/"   --exclude="htdoc/"  --exclude="www/"       $qa_svn_gamecode_dir/  $qa_gamecode_dir

rsync -avz --exclude=".svn" --exclude="tools/"      $qa_svn_pubcode_dir/     $qa_gamecode_dir/www/prod/s1/

sudo service php-fpm reload



