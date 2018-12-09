#!/bin/bash
#公司bbs网站备份
/usr/bin/rsync -vzrtopg 115.239.196.113::jidongweb    /data/backup/jidongweb/jidongweb --bwlimit=500
/usr/bin/rsync -vzrtopg 115.239.196.113::nginx_conf    /data/backup/jidongweb/nginx_conf --bwlimit=500
