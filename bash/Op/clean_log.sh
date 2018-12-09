#!/bin/bash
#删除备份日志脚本 每周一凌晨2点执行
#1 2 * * 1  /bin/sh /data/backup/clean_log.sh  &> /tmp/clean_log.log
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/sengoku/bin
HOSTNAME=$(hostname)
IP=$(ifconfig eth0 | awk -F: '/inet addr/{print $2}' | awk '{print $1}')
START_DATE=$(date -d "7 days ago" +%Y%m%d)
NOW_DATE=$(date +%Y%m%d)
BACK_FORMAT="${START_DATE}_${NOW_DATE}.log.gz"
LOG_DIR=$(sudo find / -name "*log*" -type d|grep -E -v 'mysql|mongo|redis' ) 
for dir in  $LOG_DIR
do
	echo -e "************ \e[31m 当前所在目录： $dir \e[0m *******************"
	#打包变更时间在六天前的日志
	find $dir -name "*.*log" -mtime +6 -exec tar Pzcvf $dir/${BACK_FORMAT} {} \;
	#打包后删除6天前的日志
	find $dir -name "*.*log" -mtime +6 -exec rm -fv  {} \;
	#压缩6天内日志大小超过200M的文件
	find $dir -name "*.*log" -mtime -6 -size +200M  -exec gzip {} \;
	#删除一个月前的日志备份文件
	find $dir -name "*.*log.gz" -mtime +30 -exec rm -fv  {} \;
done 
