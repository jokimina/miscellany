#!/bin/bash
#rundeck qa
BAK_DIR="/data/backup/rundeck/qa/"
DIR="`date +%Y%m%d`.tgz"
OLD_DIR="`date --date '7 days ago' +%Y%m%d`.tgz"
/bin/tar Pzcvf "${BAK_DIR}qa.${DIR}"  --exclude=${BAK_DIR}*.tgz --exclude=${BAK_DIR}rundeck ${BAK_DIR} && echo "success !!!" 
#remove 7 days ago files
rm -f "${BAK_DIR}qa.${OLD_DIR}"

#rundeck online
BAK_DIR="/data/backup/rundeck/online/"
/bin/tar Pzcvf "${BAK_DIR}online.${DIR}"  --exclude=${BAK_DIR}*.tgz --exclude=${BAK_DIR}rundeck ${BAK_DIR} && echo "success !!!" 
#remove 7 days ago files
rm -f "${BAK_DIR}online.${OLD_DIR}"

#crontab 
BAK_DIR="/data/backup/config/crontab/"
/bin/tar Pzcvf "${BAK_DIR}crontab.${DIR}" ${BAK_DIR}  --exclude=*.tgz --exclude=rundeck/* && echo "success !!!" 
#remove 7 days ago files
rm -f "${BAK_DIR}crontab.${OLD_DIR}"
