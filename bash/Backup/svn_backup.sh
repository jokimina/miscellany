#!/bin/bash
#公司SVN备份
/usr/bin/rsync -vzLrtopg 10.10.41.5::svn    /data/backup/svn 

