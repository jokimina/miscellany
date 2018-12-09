#!/bin/bash
# 清除指定端口应用的监听FD
echo 0 > /proc/sys/kernel/yama/ptrace_scope

PORT=8282
PID=$(netstat -lnpt | grep $PORT | grep -Po '\d+(?=/)')
HEX_PORT=$(printf "%04X" $PORT| tr '[a-z]' '[A-Z]')
PORT_INODE=$(grep -i $HEX_PORT /proc/net/tcp  /proc/net/tcp6 | awk '$2~/'$HEX_PORT'/||$3~/'$HEX_PORT'/{if(length($11)>2)print $11 }')

TMP_FILE="/tmp/close_fd"
echo "mkdir tmp gdb command file."
[ -f "$TMP_FILE" ] && rm -f $TMP_FILE
for i in $(echo $PORT_INODE);do echo "call close($i)">>$TMP_FILE;done;echo -e "detach\nquit">> $TMP_FILE

gdb -p $PID -x $TMP_FILE

