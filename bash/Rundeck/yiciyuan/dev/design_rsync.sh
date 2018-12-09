#!/bin/bash
platform=$1

design_dir="/data/gintama/dev_default/hot_resource/$platform/design"

if [ -d "$design_dir" ];then
	svn update $design_dir
	echo "ok!"
else
	svn co https://svn.jidongnet.com/svn/GINTAMA/dev/design/${platform}_design/ $design_dir
	[ $? -ne 0 ] && exit 1
fi
echo "------------------->     $design_dir"

