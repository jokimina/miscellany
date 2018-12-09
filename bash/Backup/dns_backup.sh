#!/bin/bash
#同步dns服务器上的etc配置文件
/usr/bin/rsync -vzrtopg   jidong@10.10.41.10::dns /data/backup/dns/etc/  --password-file=/etc/rsync.password 
[ $? -ne 0 ] && echo "etc文件同步失败" || echo "完成"
#同步dns服务器上的区域文件
/usr/bin/rsync -vzrtopg   jidong@10.10.41.10::zone /data/backup/dns/zone/  --password-file=/etc/rsync.password 
[ $? -ne 0 ] && echo "区域文件同步失败" || echo "完成"
exit 0
