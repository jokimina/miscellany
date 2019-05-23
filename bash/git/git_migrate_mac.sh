#!/bin/bash

BASE_DIR=$1
if [ -z $BASE_DIR ];then
    echo "Execute: 'bash git_migrate_mac.sh \$CODE_DIR'"
fi


CODE_DIRS=$(find $BASE_DIR -type d -name "*.git" | sed 's/\/.git//g')

for dir in $CODE_DIRS
do
    git_config=$(find $dir -type f -name 'config' | grep '.git')
    search_result=$(cat $git_config | grep 'code.old.com') 
    if [[ ! -n $search_result ]];then
        echo "## $dir Not repository from old...skip"
    else
        echo "## Modify $git_config in $dir..."
        sed "s/code.old.com/code.new.com/g" $git_config
        echo "## Check $dir done."
    fi
done
