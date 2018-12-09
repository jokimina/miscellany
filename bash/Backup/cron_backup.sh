#!/bin/bash
#同步crontab配置文件

#战国
rsync -vzrtopg 60.191.203.70::crontab /data/backup/config/crontab/zhanguo/60.191.203.70  --exclude=sengoku
rsync -vzrtopg 101.69.177.57::crontab /data/backup/config/crontab/zhanguo/101.69.177.57  --exclude=sengoku
rsync -vzrtopg 101.69.180.41::crontab /data/backup/config/crontab/zhanguo/101.69.180.41  --exclude=sengoku
rsync -vzrtopg 60.191.203.12::crontab /data/backup/config/crontab/zhanguo/60.191.203.12  --exclude=sengoku

#加勒比
rsync -vzrtopg 203.81.20.80::crontab /data/backup/config/crontab/zhanguo/203.81.20.80 
#项目三 
rsync -vzrtopg 115.231.94.215::crontab /data/backup/config/crontab/gintama/115.231.94.215
#战国bi
rsync -vzrtopg 60.191.203.62::crontab /data/backup/config/crontab/zhanguo/60.191.203.62
#加勒比bi
rsync -vzrtopg 115.239.196.40::crontab /data/backup/config/crontab/jialebi/115.239.196.40
