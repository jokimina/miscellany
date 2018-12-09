platform=dream_android
resource_main_new=/data/gamecode/$platform/new/$platform.rdb
redis_port=6400
resource_main_old=dump${redis_port}_${platform}_main_master.rdb
rsync -avz -e 'ssh  -p 40022'  $resource_main_new      jidong@192.168.1.247:/data/new/redis/
ssh -p 40022 jidong@192.168.1.247 "cp /var/lib/redis/$resource_main_old /data/backup/redis/;sudo service redis$redis_port stop;sudo cp /data/new/redis/$platform.rdb /var/lib/redis/$resource_main_old;sudo service redis$redis_port start;"




  hot_version_file=/data/jialebi_demo_gamecode/dream_android/game_server/hot_version.txt
  hot_version_update=$(awk -F":" '/hot_version/{print $2}' $hot_version_file)
  gmconfig=/var/www/html/caribbean_backend_mengxiang/protected/apps/caribbean/config/api.yml
  echo -e "\e[034mChanging GM Backend Version\e[0m"
  gmversion=$(ssh   wangdeyuan@101.231.68.46 "grep -A2 caribbean_android $gmconfig|awk -F":" '/hotver/{print \$2}'")
  echo "$gmversion"
  echo -e "\e[034mThe Current GM Backend Version is $gmversion\e[0m"
  gmversion_new=${hot_version_update}
  echo -e "\e[034mThe New GM Backend Version Will be Changed to $gmversion_new\e[0m"
  ssh -t  wangdeyuan@101.231.68.46  "sudo sed  -i  "/caribbean_android/,+2s/hotver:$gmversion/hotver:$gmversion_new/"  $gmconfig"
