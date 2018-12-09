
ssh -t  wangdeyuan@101.231.68.46 "ssh sengoku@10.10.41.42 'cd /data/tools/updatecode/channels_xc/;sh update_channels_xinchang_logincode.sh'"
login_server=10.4.14.171
logincode_new_dir=/data/logincode/channels_xc/new/
ssh -t sengoku@$login_server "rsync -avz /data/xinchang_app/login_server/  /data/logincode/backup/$(date +%Y-%m-%d-%H)"
rsync -avz --exclude "config"  --exclude "include/maintenance.php"    $logincode_new_dir   10.4.14.171::login_code
