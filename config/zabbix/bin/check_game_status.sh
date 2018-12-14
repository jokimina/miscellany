#!/bin/bash
#check game status every 3 minutes
#written by John Wang

sh /usr/local/zabbix/share/zabbix/externalscripts/monitor_game_status.sh > /tmp/game_status.txt
status=$(cat /tmp/game_status.txt)

if [ "$status" != "" ];then
   echo $status|mail -s "Can not login into the games below" wangdy@jidonggame.com 
   /usr/bin/php /usr/local/zabbix/share/zabbix/alertscripts/fetion.php  13816718592  $status
fi
