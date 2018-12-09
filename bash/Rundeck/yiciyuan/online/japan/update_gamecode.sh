#!/bin/bash
#platform=jidong
#test_or_run=test,run
platform=$1
test_or_run=$2

testrun=""
comment=""

tmp_file="/tmp/${platform}_upcode.log"

function rsync_code () {
        serverlist=/data/tools/gamecode_rsync/$platform/serverlist.txt
        host_base=$(awk '{print $1}' $serverlist|sort|uniq)
        user=gintama
        source=/data/gintama_demo_gamecode/$platform/game_code
        dest=game_code
        num=$(cat $serverlist |wc -l)

        for i in $(seq 1 $num)
        do
        echo -e "###############\e[105mRsync Code Source $source\e[0m################"
                for line in "$(awk "NR==$i" $serverlist)"
                do
                host=$( echo $line|awk '{print $1}')
                rsync  $testrun   -avz   --exclude ".svn/"   $source/   $user@"$host"::"$dest"/$platform/game_code/ &> $tmp_file
                cat $tmp_file
                error=$(grep -P 'rsync.*:|error' $tmp_file)
                error=${error:-"null"}
                if [ $error == "null" ];then
                        echo "ok!!!" 
                else
                        echo "########################## error !!!! #######################"
                        echo "$error" | xargs -n1 -i echo "!!! {} !!!"
                        exit 1
                fi


                echo -e "########################\e[105m$host :: \e[1m$dest\e[0m  Finished\e[0m########################"
                done
        done
#reload php-fpm       
        for host1 in $host_base
        do
        echo  -e  "\e[103mcurrent host is $host1\e[0m"
                if [ "$comment" == "" ];then
                   ssh -t   $user@$host1 'sudo service php-fpm reload'
                fi
        done

                   }

if [ "$platform" != "" -a "$test_or_run" != "" ];then

case $test_or_run in
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
             echo "wrong arguments"
          ;;
esac

else
             echo -e  "\e[102mUsage: sh  $0 jidong   {test|run}\e[0m"
fi                                      
