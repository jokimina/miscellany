user=jidong
######### 合服列表 ##########
#gamelist=$(cat /data/tools/gamecode_rsync/dream_android/gamelist.txt.tmp)
gamelist=$(cat /data/tools/gamecode_rsync/dream_android/gamelist.txt.weihefu)
########  线上列表 ###########
#gamelist=$(cat /data/tools/gamecode_rsync/dream_android/gamelist.txt)
tmp_file_dir=/var/www/html/dream_android/game_server/www/prod

##########################################
#finish_guide.php 新手引导
#guildbattle_rank.php  工会战奖励
#del_guildbattle_data.php  工会战清除
#reset_buy_goods.php 重置首冲
file=reset_buy_goods.php

    for server_num in ${gamelist}
    do
	echo "$server_num::::::"
   	#rsync -avz $file  192.168.1.183::game_server/dream_android/game_server/www/prod/${server_num}/workers/$file
        ssh -p 40022  -t ${user}@192.168.1.183  "php   ${tmp_file_dir}/${server_num}/workers/$file"
        #ssh -p 40022  -t ${user}@192.168.1.183  "head ${tmp_file_dir}/${server_num}/workers/$file"
        #ssh -p 40022  -t ${user}@192.168.1.183  "cp -fv $tmp_file_dir/$server_num/game.conf.php $tmp_file_dir/$server_num/game.conf.php20150710;sed -i  \"/\/\/nextid/i   \        \/\/guildbattle \n\
        #'guildbattle' => array(            \n\
        #        'host' => '192.168.1.188', \n\
        #        'port' => 8888, \n\
        #        'db' => 0, \n\
        #),\" $tmp_file_dir/$server_num/game.conf.php;php -l $tmp_file_dir/$server_num/game.conf.php"
    done

#/var/www/html/dream_ios/game_server/www/prod/s1/workers/daily_match.php
