#备份nginx域名转发上的配置
rsync -avz 10.10.41.10::nginx /data/backup/nginx/10.10.41.10/
cd /data/backup/nginx 
tar zcvf nginx_`date +%Y%m%d`.tar.gz ./ --exclude "*.gz"
rm -f nginx_`date -d "1 days ago" +%Y%m%d`.tar.gz
