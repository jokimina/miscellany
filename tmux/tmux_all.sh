#!/bin/bash
KEY_WORD=${1:?need a parameter}
USER=${2:-xxxxx}
WINDOW_NAME="${KEY_WORD}-all"
WORK_SESSION="j-work"
HOST_FILE="/etc/hosts"
declare -A SSH_HASH

SSH_HASH=(
    ["testing"]="xxxxx-testing xxxxx-testing02 xxxxx-testing04 xxxxx-testing03 xxxxx-testing05"
)

all_hosts="${SSH_HASH[$KEY_WORD]}"
hosts=${all_hosts:?no hosts get!}
host_first=$(echo $hosts| awk '{print $1}')
hosts_count=$(echo $hosts| awk '{print NF}')
tmux new-window -t $WORK_SESSION -n "$WINDOW_NAME" "ssh $USER@${host_first}" 
if [ $hosts_count -gt 1 ];then
    count=1
    for _host in $(echo $hosts| xargs -n1)
    do
        let count++
        [ $count -eq 2 ] && continue
        tmux split-window  -t $WINDOW_NAME "ssh $USER@${_host}" 
        tmux next-layout  -t $WINDOW_NAME
    done
fi
tmux set-window-option synchronize-panes on  
if [ -z $TMUX ] ;then
    tmux attach-session -t $WORK_SESSION
fi