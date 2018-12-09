#!/usr/local/bin/bash

####################################################################

ip_route_helper() {
    net1='192.168.0.0/16'

    if netstat -rn | grep -q "$net1" ; then
        route del $net1 || error "Error: failed to remove $net1"
    fi
}

change_freebsd_routes() {
    net1='192.168.0.0/16'
    route_conf_file=/etc/rc.conf

    [[ -f ${route_conf_file}.original ]] && cp ${route_conf_file}.original $route_conf_file
    ip_route_helper
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
	    change_freebsd_routes
			;;
        *)
            error "Error: unknow platform: [$result]"
			;;
    esac
	
    echo 'remove route 192.168.0.0/16 success !'
}

change_routes

####################################################################
