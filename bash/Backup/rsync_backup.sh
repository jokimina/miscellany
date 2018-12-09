#!/bin/bash
#信长
/usr/bin/rsync -vzrtopg 101.69.178.138::rsync_conf/rsyncd.conf  /data/backup/config/rsync/zhanguo_xc/101.69.178.138

#战国
/usr/bin/rsync -vzrtopg 60.191.203.12::rsync_conf/rsyncd.conf  /data/backup/config/rsync/zhanguo/60.191.203.12
/usr/bin/rsync -vzrtopg 101.69.180.41::rsync_conf/rsyncd.conf  /data/backup/config/rsync/zhanguo/101.69.180.41
/usr/bin/rsync -vzrtopg 101.69.177.57::rsync_conf/rsyncd.conf  /data/backup/config/rsync/zhanguo/101.69.177.57
/usr/bin/rsync -vzrtopg 60.191.203.70::rsync_conf/rsyncd.conf  /data/backup/config/rsync/zhanguo/60.191.203.70
#加勒比 
/usr/bin/rsync -vzrtopg 203.81.20.80::etc/rsyncd.conf  /data/backup/config/rsync/jialebi/203.81.20.80
#bi服务器
/usr/bin/rsync -vzrtopg 60.191.203.62::rsync_conf/rsyncd.conf  /data/backup/config/rsync/bi/60.191.203.62
#加勒比bi服务器
/usr/bin/rsync -vzrtopg 115.239.196.40::rsync_conf/rsyncd.conf  /data/backup/config/rsync/bi/115.239.196.40
#BBS网站
/usr/bin/rsync -vzrtopg 115.239.196.113::rsync_conf/rsyncd.conf  /data/backup/config/rsync/web_bbs/115.239.196.113
