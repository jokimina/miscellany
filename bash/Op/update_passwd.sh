#!/bin/bash
# 每月自动修改一次线上root密码
# 0 0 25 * * /bin/bash /data/tools/update_passwd.sh
# set -x
date +"%F %R"
declare -A INFO_DICT
CONF_PATH="/etc/puppet/environments/production/modules/site/manifests"
BACK_PATH="/data/backup/"
MAIL_TO="fuxiaodong@xxxxx.com|zhanglei@xxxxx.com|aaronwu@xxxxx.com|wangjianzhong@xxxxx.com"
#MAIL_TO="fuxiaodong@xxxxx.com"
DATA_FORMAT=$(date +%Y%m%d)
CONF_FILE_LIST=$(find $CONF_PATH -maxdepth 1 -type f -name "node_group_*.pp")
#CONF_FILE_LIST=$(find $CONF_PATH -maxdepth 1 -type f -name "node_group_tool.pp")
info_str="file | random_password | md5_string"
zip_pwd=$(openssl rand -base64 25| cut -c 1-25 | tr -d "/")

for conf_file in $CONF_FILE_LIST
do
    salt=$(openssl rand -hex 3)
    rand_pwd=$(openssl rand -base64 25| cut -c 1-25)
    md5_str=$(openssl passwd -1 -salt $salt $rand_pwd)
    echo  "############  backup old file"
    back_file="${BACK_PATH}/${conf_file##*/}${DATA_FORMAT}"
    cp -pv $conf_file $back_file
    sed -ri  '/root/,/password/s#(password => '\'')(.*?)('\'',)#\1'$md5_str'\3#' $conf_file
    # 修改出错回滚
    if [ $? -ne 0 ];then
        cp -pvf  $back_file $conf_file
        /usr/bin/python /data/tools/sendmail.py "fuxiaodong@xxxxx.com" "【$DATA_FORMAT】 密码修改失败!已回滚备份."        
        exit 127
    fi
    # join string
    INFO_DICT[$conf_file]="$rand_pwd | $md5_str"
done

for i in ${!INFO_DICT[@]}
do
    info_str="${info_str}\n$i | ${INFO_DICT[$i]}"
done

touch ${zip_pwd}.zip 
/usr/bin/python /data/tools/sendmail.py "fuxiaodong@xxxxx.com" "【$DATA_FORMAT】 ...." "${zip_pwd}.zip" 

echo -e "$info_str" | column -t | zip -ve -P${zip_pwd}  ${DATA_FORMAT}.zip -
/usr/bin/python /data/tools/sendmail.py "$MAIL_TO" "【$DATA_FORMAT】 密码变更!" ${DATA_FORMAT}.zip

find /data/tools -maxdepth 1 -type f -name "*.zip" -exec rm -f {} \;
echo '------------------------------------------'