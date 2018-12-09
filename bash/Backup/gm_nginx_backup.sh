#备份GM上的nginx配置
rsync -avz 10.10.41.15::gm_nginx /data/backup/nginx/10.10.41.15/
cd /data/backup/nginx/10.10.41.15/
tar zcvf gm_nginx_`date +%Y%m%d`.tar.gz ./ --exclude "*.gz"
rm -f nginx_`date -d "1 days ago" +%Y%m%d`.tar.gz

