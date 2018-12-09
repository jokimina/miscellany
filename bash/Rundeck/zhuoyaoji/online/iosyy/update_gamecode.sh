#!/bin/bash
#platform=jidong
#test_or_run=test,run

set -x 
platform=$1
test_or_run=$2
server_num=$3

testrun=""
comment=""
environment=prod

tmp_file="/tmp/${platform}_upcode.log"
#set -x 
function init() {
                server_num_type=$(echo $server_num| grep -Po ',|-'|head -n1)

                if [ x$server_num_type == x"," ];then
                        server_list=$(echo $server_num| grep -Po '\d+(?=,)|(?<=,)\d+')
                elif [ x$server_num_type == x"-" ];then
                        start_num=$(echo $server_num|grep -Po '\d+(?=-)')
                        end_num=$(echo $server_num|grep -Po '(?<=-)\d+')
                        server_list=$(echo $server_num| seq $start_num $end_num)
                elif [[ $server_num =~ [0-9] ]];then
                        server_list=$server_num
                else
			echo -e '################## !!!!!!!!!!   server number not select !    !!!!!!!  ############'
    			echo -e '################### !!!!!!!!!!! no resource will generate  !!!!!!! ################'	
                fi

                #保存需要更新的资源列表
                echo "$server_list" > /tmp/server_list.txt
}

function rsync_code () {
        serverlist=/data/tools/gamecode_rsync/iosyyace/serverlist.txt
        host_base=$(awk '{print $1}' $serverlist|sort|uniq)
        user=immortal
        source=/data/immortal_demo_gamecode/$platform/
        dest=game_code
        num=$(cat $serverlist |wc -l)

        for i in $(seq 1 $num)
        do
        echo -e "###############\e[105mRsync Code Source $source\e[0m################"
                for line in "$(awk "NR==$i" $serverlist)"
                do
                host=$( echo $line|awk '{print $1}')
		
                rsync  $testrun   -avz --exclude "index.php"  --exclude "xls/" --exclude ".svn/" --exclude "conf/"   --exclude "vendor/" --exclude "logs/"  $source/   $user@"$host"::"$dest"/$platform/  | tee  $tmp_file
		#
		echo "#######################################       resource   #############################################"
                rsync  $testrun   -avz --delete  $source/hotupdate/   $user@"$host"::"$dest"/$platform/hotupdate/  | tee  $tmp_file
		
	        #rsync -avz   --exclude ".svn/"    --exclude "conf/"  --exclude "dev/" --exclude "local/" --exclude "logs/" --exclude "vendor/" --exclude "xls/"    /data/immortal_demo_gamecode/$platform/  $user@"$host"::"$dest"/$platform/  &>  $tmp_file
		cat $tmp_file
                error=$(grep -P 'rsync.*:|error[^.]' $tmp_file )
                error=${error:-"null"}
                if [ "$error" == "null" ];then
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
                   ssh -t $user@$host1 "sudo service php-fpm reload"
                fi
        done



                   }

function gen_resource(){
if [ ! -z $server_num ];then
    cd /data/immortal_demo_gamecode/$platform/
    for num in $server_list
    do   
           echo -e "\nwrite server  $num to mongo -- version "
	   if [ "$test_or_run" == "test" ];then
		  echo  "------------  test !! -------------------"
	          echo  "php  public/index.php -p $platform -e $environment -s $num -i version/update"
	   elif [ "$test_or_run" == "run" ];then
	         echo  "php  public/index.php -p $platform -e $environment -s $num -i version/update"
		if  php  public/index.php -p $platform -e prod -s 1 -i version/update/v/$version | grep 'errorId' ;then
			echo "generate server $server_num  resource  failed!!!!!"	
			exit 1
		else 
			echo "generate server $server_num resource ok .."
		fi
	  fi
    done 
else
    echo '###################  no resource generated !！ ################'	
fi
}

if [ "$platform" != "" -a "$test_or_run" != "" ];then

case $test_or_run in
        test)
             echo -e "\e[102mNotice! This will not really transfer any files,just test what files will be sent\e[0m"
             testrun="--dry-run"
             comment="#"
             echo "$testrun"
             echo "$comment"
	     init 
             rsync_code
             gen_resource 
           ;;
         run)
             echo "$testrun"
             echo "$comment"
	     init
             rsync_code
 	     gen_resource
           ;;
          *)
             echo "wrong arguments"
          ;;
esac

else
             echo -e  "\e[102mUsage: sh  $0 jidong   {test|run}\e[0m"
fi                                      
