#!/bin/bash

#信长
/usr/bin/rsync -vzrtopg 101.69.178.138::redis_conf /data/backup/config/redis/zhanguo_xc/101.69.178.138

#际动IOS游戏服一组  一区到六区
/usr/bin/rsync -vzrtopg 101.69.177.57::redis_conf /data/backup/config/redis/zhanguo/101.69.177.57

#际动IOS游戏服二组 七区到12区 
/usr/bin/rsync -vzrtopg 60.191.203.70::redis_conf /data/backup/config/redis/zhanguo/60.191.203.70
#加勒比redis 
/usr/bin/rsync -vzrtopg 203.81.20.80::redis_conf/redis* /data/backup/config/redis/jialebi/203.81.20.80

