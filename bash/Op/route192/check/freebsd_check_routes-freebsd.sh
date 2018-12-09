#!/usr/local/bin/bash

####################################################################

check_freebsd_routes() {
    net1='192.168.0.0/16'
    if ! netstat -rn | grep -q "$net1" ; then
        echo "no"
    else
        echo "yes"
    fi
    
}

####################################################################

error() {
    echo $1
    exit 1
}

change_routes() {

    result=$(uname -a | egrep -o 'FreeBSD' | uniq | head -n 1)
    case $result in
        'FreeBSD')
	    check_freebsd_routes
			;;
        *)
            error "Error: unknow platform: [$result]"
			;;
    esac
}

change_routes

####################################################################
