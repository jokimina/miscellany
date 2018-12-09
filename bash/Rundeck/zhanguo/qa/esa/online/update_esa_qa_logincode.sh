#!/bin/bash
platform=esa
version=1.8.0
qa_logincode_dir=/data/zhanguo_app/$platform/login_server/
rsync -avz /data/svn/$platform/$version/front_server/  --exclude ".svn" --exclude "config/" $qa_logincode_dir    
