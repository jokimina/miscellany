#!/usr/local/bin/bash

####################################################################

ip_route_helper() {
    net1='192.168.0.0/16'

    gw=$(route get 10.0.0.0 | awk '/gateway/ {print $2}')
    iface=$(route get 10.0.0.0 | awk '/interface/ {print $2}')

    [[ -z "$gw" ]] && error "Error: the default gw: [$gw] is empty"

    route_entry_1="-net $net1 $gw"

    if ! netstat -rn | grep -q "$net1" ; then
        route add $route_entry_1 || error "Error: failed to add $route_entry_1"
    fi
}

change_freebsd_routes() {
    net1='192.168.0.0/16'
    route_conf_file=/etc/rc.conf

    gw=$(route get 10.0.0.0 | awk '/gateway/ {print $2}')
    iface=$(route get 10.0.0.0 | awk '/interface/ {print $2}')

    [[ -f $route_conf_file ]] && cp $route_conf_file ${route_conf_file}.original
    ip_route_helper
    route_entry_1="-net $net1 $gw"

    if ! grep -q "192\.168\.0\.0" $route_conf_file >& /dev/null; then
	static_routes=$(awk -F\" '/static_routes/ {print $2}' $route_conf_file)
	sed -i -e "s/$static_routes/$static_routes netaliinternal100/g" $route_conf_file
        echo route_netaliinternal100="\"$route_entry_1\"" >> $route_conf_file
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
	    change_freebsd_routes
			;;
        *)
            error "Error: unknow platform: [$result]"
			;;
    esac
	
    echo 'add route 192.168.0.0/16 success !'
}

change_routes

####################################################################
