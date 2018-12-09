platform=$1
sudo find  /data/immortal_app/$platform/hotupdate/ -mindepth 2  -exec rm -frv {} \;
