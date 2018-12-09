#!/bin/bash
#对bug系统mantis配置文件的备份
/usr/bin/rsync -vzrtopg 10.10.41.15::mantis /data/backup/mantis/bugtracker
/usr/bin/rsync -vzrtopg 10.10.41.15::mantis_mysql /data/backup/mantis/mysql --exclude="back_mysql.sh"
