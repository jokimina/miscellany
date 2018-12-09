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
$argv = array_slice($_SERVER['argv'], 1);
if (empty($argv) || !isset($argv[0]))
{
    echo "plase use php cron_start_country.php battle_num \n";
    exit;
}
$battle_num = (int)$argv[0];
if($battle_num < 1 && $battle_num >= Player_Const::COUNTRY_BATTLE_GROUP_MAX_NUM/2){
    echo "plase battle_num gt COUNTRY_BATTLE_GROUP_MAX_NUM \n";
    exit;
}
$_country_handle = new MongoFactory('country');
$_data = $_country_handle->use_collection(NameMapper::get_country_uid_list_collection_name())->find();
//如果报名的人数不够则 不再进行国战
if( $_data->count() <= Player_Const::COUNTRY_BATTLE_GROUP_MAX_NUM/2 || ($_data->count() <= Player_Const::COUNTRY_BATTLE_GROUP_MAX_NUM/2 && $battle_num == Player_Const::COUNTRY_BATTLE_GROUP_MAX_NUM/2) ){
    echo "plase user num  lt COUNTRY_BATTLE_GROUP_MAX_NUM/2";
    exit;
}
foreach ($_data as $r){
	print_r($r);
}
if($battle_num == Player_Const::COUNTRY_BATTLE_GROUP_MAX_NUM/2){
    $_country_handle->use_collection(NameMapper::get_country_uid_list_collection_name())->createIndex(array('uid' => 1), array('unique' => true));
    $_country_handle->use_collection(NameMapper::get_country_samurai_collection_name())->createIndex(array('uid' => 1), array('unique' => true));
    $_country_handle->use_collection(NameMapper::get_country_family_collection_name())->createIndex(array('uid' => 1), array('unique' => true));
    $_country_handle->use_collection(NameMapper::get_country_vassal_collection_name())->createIndex(array('uid' => 1), array('unique' => true));
    $_country_handle->use_collection(NameMapper::get_country_backpack_collection_name())->createIndex(array('uid' => 1), array('unique' => true));
    $_country_handle->use_collection(NameMapper::get_country_hp_collection_name())->createIndex(array('uid' => 1), array('unique' => true));
}
$_data = $_country_handle->use_collection(NameMapper::get_country_uid_list_collection_name())->find(array('rank' => (int)$battle_num*2,'battle_num'=>(int)$battle_num*2,));
$count = $_data->count();
$count = ceil($count/2);
if(empty($count)){
	echo 'Error count:',$count,PHP_EOL;
	exit();
}
$uid = 'de721bcef5cba1fc182d186d98afe072';
list($player, $ret) = Player::instance($uid);
$player_country_handle = $player->get_player_class_handle('country');
for($i = $count; $i>0;$i--){
    $player_country_handle->attack($battle_num);
}
echo date("Y-m-d H:i:s") . "|cron_start_country end \n";
