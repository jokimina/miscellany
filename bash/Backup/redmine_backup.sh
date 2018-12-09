#!/bin/bash
#备份redmin的配置文件
rsync -vzrtopg 10.10.41.105::Redmine /data/backup/redmine/conf
rsync -vzrtopg 10.10.41.105::Redmine_data /data/backup/redmine/data
