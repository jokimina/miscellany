#!/bin/bash
_PID=$(ps -e -o uid,pid,pcpu,pmem,cmd  --sort=-pcpu | awk 'NR<10&&/java/{print $2;exit}')
_TMP="/tmp/jstack_${_PID}"
jstack $_PID > $_TMP
echo "### dump stack to  $_TMP ..."
HEX_TID=$(printf "%x\n" $(top -H -b -n 1 -p ${_PID} |  awk '$1~/[0-9]/{print $1;exit}'))
echo "## Thread nid=$HEX_TID status ..."
grep -n -A 10 -B 10 $HEX_TID $_TMP
