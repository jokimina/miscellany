#!/bin/bash
platform=$1

sound_dir="/data/gintama/dev_default/hot_resource/$platform/sound"

if [ -d "$sound_dir" ];then
	svn update $sound_dir
	echo "ok!"
else
	svn co https://svn.jidongnet.com/svn/GINTAMA/dev/design/${platform}_sound/ $sound_dir
fi
echo " ------------>    $sound_dir"

