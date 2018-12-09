#!/bin/bash
user=sengoku
hostfile=/data/tools/gamecode_rsync/kaiying/serverlist.txt
IP=$(awk '{print $1}' $hostfile | sort -n | uniq )
sourcefile=/data/backup/backup_log.sh
NOW_DATE=$(date +%Y%m%d%M)
# this script is for synchronizing script!
for ip in $IP
do
#       ssh -t $user@$ip "sudo yum install -y mail;sudo sh  /data/backup/backup_log.sh"
        rsync -avz $sourcefile $ip:/data/backup/ 
#        ssh -t $user@$ip  "
#                sudo crontab -l > crontab${NOW_DATE}.bak;
#                echo '0 2 * * 1 /data/backup/backup_log.sh  >> /tmp/backup_log.log' > cron.txt;
#                sudo crontab -l >> cron.txt;
#                sudo crontab cron.txt"
done

