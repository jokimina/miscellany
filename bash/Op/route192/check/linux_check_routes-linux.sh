#!/bin/bash

####################################################################

check_route_helper() {
        net1='192.168.0.0'
        if [[ -f /sbin/ip ]]; then
            if ! /sbin/ip route | grep -q "$net1" ; then
                echo "no"
            else
                echo "yes"
            fi
        elif [[ -f /sbin/route ]]; then
            if ! /sbin/route -n | grep -q "$net1"; then
                echo "no"
            else
                echo "yes"
            fi
        else
            echo "no"
        fi
}


check_redhat_routes() {
    check_route_helper
}

check_ubuntu_routes() {
    check_route_helper
}

check_suse_routes() {
    check_route_helper
}

check_gentoo_routes() {
    if ! /sbin/route -n | grep -q '192\.168\.0\.0' ; then
        echo "no"
    else
        echo "yes"
    fi
}

check_coreos_routes() {
    check_route_helper
}

####################################################################

error() {
    echo $1
    exit 1
}

check_routes() {

    result=$(egrep -o 'Ubuntu|Red Hat|SUSE|Debian|Gentoo|Gentoo Hardened|AliCloud' /proc/version | uniq | head -n 1)
    case $result in
        'Ubuntu' | 'Debian')
			check_ubuntu_routes
			;;
		'Red Hat' | 'AliCloud')
			check_redhat_routes
			;;
		'SUSE')
			check_suse_routes
			;;
		'Gentoo')
			check_gentoo_routes
			;;
		'Gentoo Hardened')
			check_coreos_routes
			;;
		*)
			error "Error: unknow platform: [$result]"
			;;
	esac
}

check_routes

####################################################################
