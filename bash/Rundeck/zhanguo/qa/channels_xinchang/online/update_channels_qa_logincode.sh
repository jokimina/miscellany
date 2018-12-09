#!/bin/bash
platform=xinchang
version=1.2.0
qa_logincode_dir=/data/xinchang_app/channels/login_server/
rsync -avz /data/svn/$platform/$version/front_server/  --exclude ".svn" --exclude "config/" $qa_logincode_dir    
