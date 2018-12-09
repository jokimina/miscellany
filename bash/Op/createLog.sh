#!/bin/bash
# @Author:      xiaodong
# @Email:       fuxd@jidongnet.com
# @DateTime:    2015-12-15 11:35:36
# @Description: 自動建立每月日志目录及文件,设定权限避免无法写入

PATH_PLATFORM=$(find /data/app_data/ -maxdepth 1  -name "*immortal")
DATE=( $(date +%Y%m) $(date +%Y%m -d "1 month") )
LOGTPYES=( app error )

for logtype in ${LOGTPYES[@]}
do
        for logpath in $(echo $PATH_PLATFORM)
        do
            for _DATE in ${DATE[@]}
            do
                [ ! -d ${logpath}/logs/${logtype}/${_DATE} ] && mkdir -p ${logpath}/logs/${logtype}/${_DATE}
                for logfile in $(seq -f "${logpath}/logs/${logtype}/${_DATE}/%02g.log" 1 31)
                do
                        touch $logfile
                        chmod 777 $logfile
                        chown daemon:daemon $logfile
                done
           done
        done
done
