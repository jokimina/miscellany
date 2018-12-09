#!/bin/bash
platform=dream_ios
serverlist=/data/tools/gamecode_rsync/$platform/serverlist.txt
user=jidong
host_base=$(awk '{print $1}' $serverlist|sort|uniq)

source=/data/jialebi_demo_gamecode/$platform/game_server/data/operator/
dest=game_server
num=$(cat $serverlist |wc -l)

for i in $(seq 1 $num)
do
echo -e "###############\e[105mRsync Code Source $source\e[0m################"
                for line in "$(awk "NR==$i" $serverlist)"
                do
                host=$( echo $line|awk '{print $1}')
		check_file="$host.txt"
#生成校验文件
                rsync  -avz    --exclude ".svn/"     $source "$host"::"$dest"/$platform/game_server/data/operator/
#获取同步后的时间
		TIME=$(ssh -t  -p 40022  $user@$host  "cd /var/www/html/dream_ios/game_server/data/operator/;ls  | grep '^operator_list_' | xargs -n1 -i stat -c %y {} | awk -F: '{\$NF=\"\";print \$1\":\"\$2 }' | uniq")
#获取校验列表
		ssh -t  -p 40022  $user@$host  "cd /var/www/html/dream_ios/game_server/data/operator/; ls | awk '\$NF ~ /^operator_list_/{print }'| xargs -n1 -i md5sum {}   | sort -t'_' -k3 -n"  > ${check_file}


		echo " ################### $host: 开始校验...... #######################"

		CHECKSUM=$(md5sum $check_file|awk '{print $1}')
		if [ "$CHECKSUM_BEFORE" != "" ];then
			if [ "$CHECKSUM_BEFORE" == "$CHECKSUM"  ];then
				flag=0
			else
				flag=1
			fi
		fi
		
		CHECKSUM_BEFORE="$CHECKSUM"
		echo " ################### $host: 校验结束...... #######################"
		
                #echo -e "########################\e[105m$host :: \e[1m$dest\e[0m  Finished\e[0m########################"
                done
done
echo  "同步平台：dream_ios"
if [ "$flag" -eq 0 ];then
	echo "同步完成.... 检测ok !!"
	echo "文件生成时间: $TIME"
else
        echo "同步全服校验出错,请联系管理员.." 
	echo "文件生成时间: $TIME"
fi
