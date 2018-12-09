#!/bin/bash
# login_game_pool:FRONTEND
pool_name=$(echo $1|awk -F':' '{print $1}')
server_name=$(echo $1|awk -F':' '{print $2}')
metric=$2
stat_socket=/tmp/haproxy
stat_file=/tmp/haproxy_stat.csv
echo "show stat"|sudo socat stdio unix-connect:/tmp/haproxy > $stat_file

case $metric in
          qcur)
              #current queued requests
              if [ "$server_name" != "FRONTEND" ];then
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $3}' $stat_file
              else
                  echo 0
              fi
             ;;
          qmax)
              #max queued requests
              if [ "$server_name" != "FRONTEND" ];then
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $4}' $stat_file
              else
                  echo 0
              fi
             ;;
          scur)
              #current sessions
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $5}' $stat_file
             ;;
          smax)
              #max sessions
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $6}' $stat_file
             ;;
          slim)
              #sessions limit
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $7}' $stat_file
             ;;
          stol)
              #total sessions
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $8}' $stat_file
             ;;
           bin)
              #bytes in 
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $9}' $stat_file
             ;;
          bout)
              #bytes out
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $10}' $stat_file
             ;;
          dreq)
              #denied requests
              #only FRONTEND and BACKEND has this field
              if [ "$server_name" == "FRONTEND" -o "$server_name" == "BACKEND" ];then
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $11}' $stat_file
              else 
                 echo 0
              fi
             ;;
         dresp)
              #denied responses
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $12}' $stat_file
             ;;
          ereq)
              #request errors
              #only FRONTEND has this field
              if [ "$server_name" == "FRONTEND" ];then
                 awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $13}' $stat_file
              else
                 echo 0
              fi
             ;;
          econ)
              #connection errors
              #FRONTEND has not this field
              if [ "$server_name" != "FRONTEND" ];then
                 awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $14}' $stat_file
              else
                 echo 0
              fi
             ;;
         eresp)
              #response errors
              #FRONTEND has not this field
              if [ "$server_name" != "FRONTEND" ];then
                 awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $15}' $stat_file
              else
                 echo 0
              fi
             ;;
        status)
              #status
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $18}' $stat_file
              ;;
       chkfail)
              #number of failed checks
              #FRONTEND and BACKEND has not this field
              if [ "$server_name" == "FRONTEND" -o "$server_name" == "BACKEND" ];then
                 echo 0
              else
                 awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $22}' $stat_file
              fi
              ;;
       chkdown)
              #number of UP->DOWN transitions
              #FRONTEND has not this field will return 0
              if [ "$server_name" != "FRONTEND" ];then
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $23}' $stat_file
              else
                 echo 0
              fi
              ;;
       lastchg)
              #last status change in seconds
              #FRONTEND has not this field will return 0
              if [ "$server_name" != "FRONTEND" ];then
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $24}' $stat_file
              else
                 echo 0
              fi
              ;;
      downtime)
              #total downtime in seconds
              #FRONTEND has not this field will return 0
              if [ "$server_name" != "FRONTEND" ];then
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $25}' $stat_file
              else
                 echo 0
              fi
              ;;
         lbtot)
              #total number of times a server was selected
              #FRONTEND has not this field
              if [ "$server_name" != "FRONTEND" ];then
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $31}' $stat_file
              else
                 echo 0
              fi
              ;;
          rate)
              #number of sessions per second over last elapsed second
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $34}' $stat_file
              ;;
    rate_limit)
              #limit on new sessions per second
              #only FRONTEND has this field
              if [ "$server_name" == "FRONTEND" ];then
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $35}' $stat_file
              else
                  echo 0
              fi
              ;;
      rate_max)
              #max number of new sessions per second
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $36}' $stat_file
              ;;
  check_status)
              #status of last health check  
              if [ "$server_name" == "FRONTEND" -o "$server_name" == "BACKEND" ];then
                 echo "NULL"
              else
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $37}' $stat_file
              fi
              ;;
      hrsp_1xx)
              #http response with 1xx code
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $40}' $stat_file
              ;;
      hrsp_2xx)
              #http response with 2xx code
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $41}' $stat_file
              ;;
      hrsp_3xx)
              #http response with 3xx code
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $42}' $stat_file
              ;;
      hrsp_4xx)
              #http response with 4xx code
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $43}' $stat_file
              ;;
      hrsp_5xx)
              #http response with 5xx code
              awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $44}' $stat_file
              ;;
      req_rate)
              #HTTP requests per second over last elapsed second
              #only FRONTEND has this field,others will return 0
              if [ "$server_name" == "FRONTEND" ];then
                 awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $47}' $stat_file
              else
                 echo 0
              fi
              ;;
  req_rate_max)
              #max number of HTTP requests per second observed
              #only FRONTEND has this field,others will return 0
              if [ "$server_name" == "FRONTEND" ];then
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $48}' $stat_file
              else
                  echo 0
              fi
              ;;
       req_tot)
              #total number of HTTP requests recevied
              #only FRONTEND has this field,others will return 0
              if [ "$server_name" == "FRONTEND" ];then
                  awk -F"," '$1=="'$pool_name'"&&$2=="'$server_name'"{print $49}' $stat_file
              else
                  echo 0
              fi
              ;;
             *)
               echo "please input the correct argument"
              ;; 
esac
