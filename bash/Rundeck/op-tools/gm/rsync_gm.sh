#!/bin/bash
#同步SVN上的GM代码
TIME=$(date +%Y%m%d%H)
# 捉妖记 备份当前GM代码 
sudo rsync -avz /data/immortal_app/gm_code/ /data/backup/gm_code${TIME}/  &>  /dev/null
[ ! -d /data/svn/gm_code/ ] && svn co https://svn.jidongnet.com/svn/immortal/dev/server/trunk/gm_code/ /data/svn/gm_code/ || svn up /data/svn/gm_code/
echo "sync start ......"
sudo rsync --exclude ".svn" -avz /data/svn/gm_code/ /data/immortal_app/gm_code/
echo "sync done ......"

