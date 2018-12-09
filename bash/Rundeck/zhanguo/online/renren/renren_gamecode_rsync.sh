#!/bin/bash
testrun=""
comment=""

function rsync_code () {
	user=sengoku
	source=/data/zhanguo_demo_gamecode/renren/
	num=$(cat serverlist.txt |wc -l)
	for i in $(seq 1 $num)
	do  
    	echo -e "###############\e[105mRsync Code Source $source\e[0m################"
    		for line in "$(awk "NR==$i" serverlist.txt)"
    		do 
             	host=$( echo $line|awk '{print $1}')
             	dest=$( echo $line|awk '{print $2}')
             	rsync  $testrun   -aP   --exclude "config/app.conf.php*"  --exclude "htdoc/resource/*" --exclude ".svn/" $source   sengoku@"$host"::"$dest"
                if [ "$comment" == "" ];then
                   ssh -t $user@$host "sudo service php-fpm reload"                   
                fi
                echo -e "########################\e[105m$host :: \e[1m$dest\e[0m  Finished\e[0m########################"
    		done
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
           ;;
          *)
             echo -e  "\e[102mUsage: sh  $0 {test|run}\e[0m"
          ;;
esac
