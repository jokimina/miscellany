#!/bin/bash
platform=dream_ios
testrun=""
comment=""
serverlist=/data/tools/gamecode_rsync/$platform/serverlist.txt
gamelist=/data/tools/gamecode_rsync/$platform/gamelist.txt

host_base=$(awk '{print $1}' $serverlist|sort|uniq)

function rsync_code () {
        user=jidong
        source=/data/jialebi_demo_gamecode/$platform/game_server/
        dest=game_server
        num=$(cat $serverlist |wc -l)

        for i in $(seq 1 $num)
        do
        echo -e "###############\e[105mRsync Code Source $source\e[0m################"
                for line in "$(awk "NR==$i" $serverlist)"
                do
                host=$( echo $line|awk '{print $1}')
                rsync  $testrun   -avz   --exclude ".svn/"  --exclude "/data/operator"     --exclude "config/prod" --exclude "*.log"  --exclude "www"    $source   $user@"$host"::"$dest"/$platform/game_server/

                    for game in $(cat $gamelist)
                    do               
                         echo $game
                         rsync $testrun -avz --exclude ".svn" --exclude "*.log"    $source/www/prod/s10000/  $user@$host::$dest/$platform/game_server/www/prod/$game 
                    done
                   

                echo -e "########################\e[105m$host :: \e[1m$dest\e[0m  Finished\e[0m########################"
                done
        done
#reload php-fpm       
        for host1 in $host_base
        do
        echo  -e  "\e[103mcurrent host is $host1\e[0m"
                if [ "$comment" == "" ];then
                   ssh -t $user@$host1 -p 40022 "sudo service php-fpm reload"
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
           ;;
          *)
             echo -e  "\e[102mUsage: sh  $0 {test|run}\e[0m"
          ;;
esac
                                      
