#!/bin/bash
#同步所有rundeck配置文件 和 script文件
now_date=$(date +%Y%m%d)

#=====================================     qa 测试环境同步     ===============================================

#同步qa的rundeck配置
/usr/bin/rsync -vzrtopg --exclude="logs" 10.10.41.42::qa_rundeck  /data/backup/rundeck/qa/rundeck/10.10.41.42
#同步qa上的脚本
/usr/bin/rsync -vzrtopg --exclude="resources" --exclude "cdn" 10.10.41.20::qa_jialebi /data/backup/rundeck/qa/jialebi/10.10.41.20
/usr/bin/rsync -vzrtopg --exclude="cdn"  10.10.41.42::qa_zhanguo /data/backup/rundeck/qa/zhanguo/10.10.41.42


#同步第三项目脚本
/usr/bin/rsync -vzrtopg --exclude "cdn" 10.10.41.17::qa_gintama      /data/backup/rundeck/qa/gintama/10.10.41.17 

#=====================================      线上同步脚本     ===============================================


#同步rundeck线上配置
/usr/bin/rsync -vzrtopg --exclude="logs" 60.191.203.12::rundeck  /data/backup/rundeck/online/rundeck/60.191.203.12

#同步rundeck线上脚本
/usr/bin/rsync -vzrtopg 203.81.20.80::jialebi     /data/backup/rundeck/online/jialebi/203.81.20.80
/usr/bin/rsync -vzrtopg 60.191.203.12::zhanguo    /data/backup/rundeck/online/zhanguo/60.191.203.12

#越南
rsync -vzrtopg 123.30.215.186::data/tools    /data/backup/rundeck/online/zhanguo/123.30.215.186
#日本
rsync -vzrtopg 54.238.140.69::game_rsync    /data/backup/rundeck/online/zhanguo/54.238.140.69
#大武士
rsync -vzrtopg 210.242.196.156::data/tools    /data/backup/rundeck/online/zhanguo/210.242.196.156
#韩国
#rsync -vzrtopg 210.65.163.115::backup/tools/    /data/backup/rundeck/online/zhanguo/210.65.163.115
#东南亚
#rsync -vzrtopg 54.254.196.119::backup/tools/    /data/backup/rundeck/online/zhanguo/54.254.196.119

#gintama际动
/usr/bin/rsync -vzrtopg 122.226.199.109::jidong_gintama  /data/backup/rundeck/online/gintama/122.226.199.109

#gintama台湾
rsync -vzrtopg 61.219.16.78::backup/tools/    /data/backup/rundeck/online/gintama/61.219.16.78

cd /data/backup/rundeck/
svn status | awk '/^?/{print $2}' | xargs -n1 -i svn add {} 
svn commit  -m  "${now_date}"
