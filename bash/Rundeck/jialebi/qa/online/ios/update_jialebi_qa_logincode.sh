#!/bin/bash
platform=dream_ios
version=0.9.1
qa_logincode_dir=/data/jialebi_app/$platform/game_center/

rsync -avz /data/svn/qa/$platform/$version/game_center/  --exclude ".svn" --exclude "config/" $qa_logincode_dir    
