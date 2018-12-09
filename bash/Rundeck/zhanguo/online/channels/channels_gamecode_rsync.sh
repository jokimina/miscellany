#!/bin/bash
testrun=""
comment=""

function rsync_code () {
	user=sengoku
	source=/data/zhanguo_demo_gamecode/360/
        serverlist=/data/tools/gamecode_rsync/channels/serverlist.txt
        host_base=$(awk '{print $1}' $serverlist|sort|uniq)
	num=$(cat $serverlist |wc -l)
	for i in $(seq 1 $num)
	do  
    	echo -e "###############\e[105mRsync Code Source $source\e[0m################"
    		for line in "$(awk "NR==$i" $serverlist)"
    		do 
             	host=$( echo $line|awk '{print $1}')
             	dest=$( echo $line|awk '{print $2}')
             	rsync  $testrun   -aP    --exclude="data/events.php"   --exclude "config/app.conf.php*"  --exclude "htdoc/resource/*" --exclude ".svn/" $source   sengoku@"$host"::"$dest"
                echo -e "########################\e[105m$host :: \e[1m$dest\e[0m  Finished\e[0m########################"
    		done
	done

##
#reload php-fpm       
        for host1 in $host_base
        do
        echo  -e  "\e[103mcurrent host is $host1\e[0m"
                if [ "$comment" == "" ];then
                   ssh -t $user@$host1 "sudo service php-fpm reload"
                fi
        done



		   }	
case $1 in
        test)
             echo -e "\e[102mNotice! This will not really transfer any files,just test what files will be sent\e[0m"
             testrun="--dry-run"
             comment="#"
             echo "$testrun"
             echo "$comment"
             rsync_code
           ;;
         run)
             echo "$testrun"
             echo "$comment"
             rsync_code
             cat serverlist.txt| mail -s "Sengoku Channels(360 based) Platform Code Deployment On $(date +%Y/%m/%d/%H/%M) Operated by $USER" wangdy@jidonggame.com wangws@jidonggame.com  xugl@jidonggame.com
           ;;
          *)
             echo -e  "\e[102mUsage: sh  $0 {test|run}\e[0m"
          ;;
esac
