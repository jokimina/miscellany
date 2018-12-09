#!/bin/bash
process_list=(nginx php-fpm crond redis redis6377 redis6378)

for process in ${process_list[@]}
do
status=$(ps -ef|grep $process|grep -v grep|grep -v $0)
if [ "$status" != "" ];then
   echo "$(date +'%Y%m%d %H:%M') $process is running "
else
   echo "$(date +'%Y%m%d %H:%M') $process is not running"
   /sbin/service $process start
fi

done
