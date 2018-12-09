#!/bin/bash
testrun=""
comment=""
function rsync_code () {
    user=sengoku
    source=/data/zhanguo_demo_gamecode/xinchang/
    serverlist=/data/tools/gamecode_rsync/xinchang/serverlist.txt 
    host_base=$(awk '{print $1}' $serverlist|sort|uniq)
    num=$(cat $serverlist |wc -l)
    for i in $(seq 1 $num)
    do  
    echo "###############Rsync Code Source $source################"
        for line in "$(awk "NR==$i" $serverlist)"
        do 
             host=$( echo $line|awk '{print $1}')
             dest=$( echo $line|awk '{print $2}')
             rsync  $testrun   -aP    --exclude="data/events.php"   --exclude "config/app.conf.php*"  --exclude "data/tools_release_events.php"  --exclude "htdoc/resource/*" --exclude ".svn/" "$source"    sengoku@"$host"::"$dest"
             echo -e  "########################\e[105m$host :: $dest\e[0m  Finished########################"
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
           echo -e "\e[106mNotice! This will not really transfer any files,just test what files will be sent\e[0m"
           testrun="--dry-run"
           comment="#"
           echo "$testrun"
           echo "$comment"
           rsync_code
           echo -e  "\e[106mNotice! This will not really transfer any files,just test what files will be sent\e[0m"
         ;;
       run)
           echo "$testrun"
           echo "$comment"
           rsync_code
           cat $serverlist|mail -s "Kaiying Platfrom Code Deployment on $(date +%Y/%m/%d/%H/%M) Operated by $USER" wangdy@jidonggame.com wangws@jidonggame.com  xugl@jidonggame.com
           echo -e "*************\e[102mAll FILES  TRANSFERED\e[0m****************"
         ;;
         *)
           echo "Usage: sh  $0 {test|run}"
         ;;
  esac
