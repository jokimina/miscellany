#!/bin/bash
#linux/UNIX
SERVERS="10.10.41.254"
# SSH User name
USR="admin"
PWD="#Firewall@jidongnet.com254"

timestamp=$(date +"%y-%m-%d")

# connect each host
for host in $SERVERS
do
scp -oStrictHostKeyChecking=no $USR@$host:sys_config /data/backup/config/firewall/"$timestamp"_"$host".conf
done
echo "${timestamp} Backup Completed!"
exit
