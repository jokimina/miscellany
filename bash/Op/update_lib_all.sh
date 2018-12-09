#!/bin/bash
_PATH=$(pwd)
ALL_LIB=$(find $_PATH -maxdepth 1 -name "xxxxx-lib*" -o -name "xxxxx-common")
for _lib_path in $ALL_LIB
do
    cd $_lib_path
    if git pull |& grep changed;then
        mvn clean install
    else
        echo "$_lib_path no change , skip..."
    fi
done