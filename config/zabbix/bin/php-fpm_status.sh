#!/bin/bash
#check php-fpm status
ip=127.0.0.1
port=88
function idle()  {
    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "idle processes"|awk '{print $3}'
                   }

function active() {
    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "active processes"|awk '{print $3}'|grep -v "processes"
                   }

function total() {
    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "total processes"|awk '{print $3}'|grep -v "processes"
                   }

function mactive() {

    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "max active processes"|awk '{print $4}'
                   }

function conn()    {
    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "accepted conn"|awk '{print $3}'
                  
                   }

function since() {
       
    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "start since"|awk '{print $3}'
                   }

function slow()   {

    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "slow requests"|awk '{print $3}'
                   }
function listenqueue() {

    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "listen queue:"|grep -v "max"|awk '{print $3}'

                       }


function maxlistenqueue() {

    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "max listen queue:"|awk '{print $4}'

                          }


function listenqueuelen() {

    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "listen queue len:"|awk '{print $4}'

                       }



function maxchildren() {

    /usr/bin/curl http://$ip:$port/php-fpm_status 2>/dev/null|grep "max children reached:"|awk '{print $4}'

                       }

$1

