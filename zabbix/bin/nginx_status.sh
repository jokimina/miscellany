#!/bin/bash
#check nginx status
#ip=$(ifconfig eth0|grep "inet addr"|sed  's/^.*addr://'|awk '{print $1}')
#echo $ip
ip=127.0.0.1
port=88
#echo $ip:$port
function active()  {
    /usr/bin/curl http://$ip:$port/nginx_status 2>/dev/null|grep "Active"|awk '{print $NF}'
                   }

function reading() {
    /usr/bin/curl http://$ip:$port/nginx_status 2>/dev/null|grep "Reading"|awk '{print $2}'
                   }

function writing() {
    /usr/bin/curl http://$ip:$port/nginx_status 2>/dev/null|grep "Writing"|awk '{print $4}'
                   }

function waiting() {

    /usr/bin/curl http://$ip:$port/nginx_status 2>/dev/null|grep "Waiting"|awk '{print $6}'
                   }

function accepts() {
    /usr/bin/curl http://$ip:$port/nginx_status 2>/dev/null|awk 'NR==3{print $1}'   
                  
                   }

function handled() {
       
    /usr/bin/curl http://$ip:$port/nginx_status 2>/dev/null|awk 'NR==3{print $2}'   
                   }

function requests(){

    /usr/bin/curl http://$ip:$port/nginx_status 2>/dev/null|awk 'NR==3{print $3}'   
                   }

case $1 in
   active)
          active
        ;;
  reading)
         reading
        ;;
  writing)
          writing
        ;;
  waiting)
          waiting
        ;;
  accepts)
          accepts
        ;;
  handled)
          handled
        ;;
  requests)
          requests
        ;;
       *)
          exit 1
        ;;
esac


