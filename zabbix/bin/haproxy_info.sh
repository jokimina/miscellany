#!/bin/bash
#This script is used for getting haproxy info such as version ,uptime and number of processes etc

metric=$1
stats_socket=/tmp/haproxy
info_file=/tmp/haproxy_info.csv
echo "show info"|/usr/bin/sudo /usr/bin/socat   unix-connect:$stats_socket  stdio > $info_file
grep $metric $info_file|awk '{print $2}'

