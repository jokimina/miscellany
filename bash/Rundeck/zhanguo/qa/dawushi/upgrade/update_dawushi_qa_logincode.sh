#!/bin/bash
platform=dawushi
version=1.0.0
qa_logincode_dir=/data/zhanguo_app/dawushi_new/login_server/
rsync -avz /data/svn/$platform/$version/front_server/  --exclude ".svn" --exclude "config/" $qa_logincode_dir    
