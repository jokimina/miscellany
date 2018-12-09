#!/bin/bash
zone=$1
user=sengoku
num=$(cat /data/tools/gamecode_rsync/kaiying/serverlist.txt |wc -l)
sourcefile=/data/zhanguo_app/login_server/include/maintenance.php
function add_all() {
for i in $(seq 1 $num)
do
    for line in "$(awk "NR==$i" /data/tools/gamecode_rsync/kaiying/serverlist.txt)"
    do
             host=$( echo $line|awk '{print $1}')
             coderoot=$( echo $line|awk '{print $3}')
             cronfile=$coderoot/include/maintenance.php
             rsync -avz $sourcefile $user@$host:${cronfile}
             echo "$host :::::"
    done
done
}

function add(){
        line=$(awk "NR==${zone}" /data/tools/gamecode_rsync/kaiying/serverlist.txt)
        host=$( echo $line|awk '{print $1}')
        coderoot=$( echo $line|awk '{print $3}')
        cronfile=$coderoot/include/maintenance.php
        rsync -avz $sourcefile $user@$host:${cronfile}
        echo "$host :::::"
}

case ${zone} in
        all)
        add_all
        ;;
        *)
        add ${zone}
        ;;
esac
