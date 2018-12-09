#!/bin/bash
#公司BI网站备份
/usr/bin/rsync -vzrtopg 60.191.203.62::bi_log    /data/backup/bi/zhanguo/logs --bwlimit=500
/usr/bin/rsync -vzrtopg 115.239.196.40::bi_log --exclude='*log'  /data/backup/bi/jialebi/logs  --bwlimit=500
#第三项目gintama_bi日志备份
/usr/bin/rsync -vzrtopg 115.231.94.215::gintama_bi_log/*tgz /data/backup/bi/gintama/logs
rsync -vzrtopg 115.231.94.215::bi /data/backup/bi/gintama/bi_analyzer

/usr/bin/rsync -vzrtopg 60.191.203.62::bi/bi_front/* /data/backup/bi/bi_front --bwlimit=500

/usr/bin/rsync -vzrtopg 60.191.203.62::bi/bi_analyzer/* /data/backup/bi/zhanguo/bi_analyzer   --bwlimit=500

/usr/bin/rsync -vzrtopg 115.239.196.40::bi        /data/backup/bi/jialebi/bi_analyzer   --bwlimit=500
