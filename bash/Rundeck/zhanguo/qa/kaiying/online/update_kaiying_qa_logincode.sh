#!/bin/bash
platform=kingnet
version=2.1.3
qa_logincode_dir=/data/zhanguo_app/kaiying/login_server/
rsync -avz /data/svn/$platform/$version/front_server/  --exclude ".svn" --exclude "config/" $qa_logincode_dir    
