#!/bin/bash

####################################################################

ip_route_helper() {
    net1="192.168.0.0/16"
    if [[ -f /sbin/ip ]]; then
        if /sbin/ip route | grep -q "$net1" ; then
            /sbin/ip route del $net1 || error "Error: failed to remove route $net1"
        fi
    elif [[ -f /sbin/route ]]; then
	    if /sbin/route -n | grep -q "$net1"; then
	        /sbin/route del -net 192.168.0.0/16  dev eth0
		fi
	fi
}

rollback_redhat_routes() {
    route_conf_file=/etc/sysconfig/network-scripts/route-eth0
    [[ -f ${route_conf_file}.original ]] && cp ${route_conf_file}.original $route_conf_file

    ip_route_helper
}

rollback_ubuntu_routes() {
    route_conf_file=/etc/network/interfaces
    [[ -f ${route_conf_file}.original ]] && cp ${route_conf_file}.original $route_conf_file

    ip_route_helper
}

rollback_suse_routes() {
    route_conf_file=/etc/sysconfig/network/ifroute-eth0
    [[ -f ${route_conf_file}.original ]] && cp ${route_conf_file}.original $route_conf_file

    ip_route_helper
}

rollback_gentoo_routes() {
    route_conf_file=/etc/conf.d/net
    [[ -f ${route_conf_file}.original ]] && cp ${route_conf_file}.original $route_conf_file

    if route -n | grep -q '192\.168\.0\.0' ; then
        route del -net 192.168.0.0/16 || error "Error: failed to remove 192.168.0.0/16"
    fi
}

rollback_coreos_routes() {
    route_conf_file=/etc/systemd/network/10-eth0.network
    [[ -f ${route_conf_file}.original ]] && cp ${route_conf_file}.original $route_conf_file
    ip_route_helper
}

####################################################################

error() {
    echo $1
    exit 1
}

rollback_routes() {

    result=$(egrep -o 'Ubuntu|Red Hat|SUSE|Debian|Gentoo|Gentoo Hardened|AliCloud' /proc/version | uniq | head -n 1)
    case $result in
        'Ubuntu' | 'Debian')
			rollback_ubuntu_routes
			;;
		'Red Hat' | 'AliCloud')
			rollback_redhat_routes
			;;
		'SUSE')
			rollback_suse_routes
			;;
		'Gentoo')
			rollback_gentoo_routes
			;;
		'Gentoo Hardened')
			rollback_coreos_routes
			;;
		*)
			error "Error: unknow platform: [$result]"
			;;
	esac
    echo 'remove route 192.168.0.0/16 success !'
}

rollback_routes

####################################################################
