#!/bin/sh
#cron:每天凌晨5点运行一次
#0 5 * * *  /bin/bash /data/backup/backup_mysql.sh &> /var/log/backup_mysql.log

backup_mysql_dir="/data/backup"
backup_mysql_host="127.0.0.1"
backup_mysql_account="zhanguo"
backup_mysql_password="zhanguo123"
current_date=$(date  +%Y%m%d)
last_date=$(date --date '3 days ago' +%Y%m%d)

if [ ! -d "${backup_mysql_dir}" ]; then
        mkdir -p ${backup_mysql_dir}
fi

/usr/bin/mysqldump -h ${backup_mysql_host} -u ${backup_mysql_account} --password="${backup_mysql_password}" --opt --all-databases |gzip > ${backup_mysql_dir}/mysql${current_date}.sql.gz  
echo "Success to backup mysql: ${backup_mysql_dir}/mysql${current_date}.sql.gz"

last_backup_file=${backup_mysql_dir}/mysql${last_date}.sql.gz

rm -f ${last_backup_file}
