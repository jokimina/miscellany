<?php
define('ROOT', dirname(__dir__));
include  ROOT . '/include/common.php';
Logger::set_name("cron_start_country");

echo date("Y-m-d H:i:s") . "|cron_start_country start \n";
$server_id = ConfigData::get('app|server_id', 1, TRUE);
$static_country_list = StaticData::read('country_list');
if(!isset($static_country_list[$server_id])){
    echo "This server_id is no longer war in the country  \n";
    exit;
}
$scountry = array();
foreach($static_country_list as $ckey => $cval){
    if($cval != $static_country_list[$server_id]) continue;
    $scountry[] = $ckey;
}
sort($scountry);
reset($scountry);
/*if(current($scountry) != $server_id){
    echo "This crontab  Return to normal\n";
    exit;
}*/
$uid = 'de721bcef5cba1fc182d186d98afe072';
list($player, $ret) = Player::instance($uid);
$player_country_handle = $player->get_player_class_handle('country');
$player_country_handle->removeprev();
$player_country_handle->initinfo();
echo date("Y-m-d H:i:s") . "|cron_start_country end \n";
