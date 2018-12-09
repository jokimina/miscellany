#!/bin/bash
platform=dream_android
serverlist=/data/tools/gamecode_rsync/$platform/serverlist.txt

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
                rsync    -avz  --exclude ".svn/"     $source "$host"::"$dest"/$platform/game_server/data/operator/

                echo -e "########################\e[105m$host :: \e[1m$dest\e[0m  Finished\e[0m########################"
                done
done
