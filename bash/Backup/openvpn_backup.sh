#!/bin/bash
#对openvpn的key和配置文件的备份
/usr/bin/rsync -vzrtopg   10.10.41.10::openvpn /data/backup/openvpn
cd /data/backup/openvpn
DIR="`date +%Y%m%d`.tgz"
OLD_DIR="`date --date '7 days ago' +%Y%m%d`.tgz"
/bin/tar zcvf "openvpn.${DIR}"  --exclude=*.tgz ./ && echo "success !!!" 
#remove 7 days ago files
rm -f "openvpn.${OLD_DIR}"
