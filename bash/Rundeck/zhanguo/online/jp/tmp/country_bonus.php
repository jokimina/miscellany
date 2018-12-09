<?php
//国战的奖励 顺便如果国战未开。也将其报名的小判归还
define('ROOT', dirname(__dir__));
include  ROOT . '/include/common.php';
Logger::set_name("cron_country_bonus");

echo date("Y-m-d H:i:s") . "|cron_country_bonus start \n";
//验证 是否存在国战中
$server_id = ConfigData::get('app|server_id', 1, TRUE);
$static_country_list = StaticData::read('country_list');
if(!isset($static_country_list[$server_id])){
    echo "This server_id is no longer war in the country  \n";
    exit;
}
$_country_handle = new MongoFactory('country');
$_data = $_country_handle->use_collection(NameMapper::get_country_uid_list_collection_name())->find();
//如果报名的人数不够则 不再进行国战
if($_data->count() <= Player_Const::COUNTRY_BATTLE_GROUP_MAX_NUM/2){
    $bonus = array('gold_buy'=>Player_Const::COUNTRY_BATTLE_COST_NUM);
    //这里将 报名的小判归还玩家
    $_data = $_country_handle->use_collection(NameMapper::get_country_uid_list_collection_name())->find(array('server_id'=>$server_id),array('uid'=>true,'server_id'=>true,'rank'=>true));
    if($_data->count()){
        foreach($_data as $data){
            if($data['server_id'] != $server_id) continue;
            if($data['uid']){
                $suid = explode("_",$data['uid']);
                $suid = end($suid);
                list($player, $ret) = Player::instance($suid);
                if($player){
                    $player->to_bonus($bonus);
                    $player->save();
                }
            }
        }
    }
}else{
    //此处将是一个多维数组
    $bonus = StaticData::read('country_rank_bonus');
    $_data = $_country_handle->use_collection(NameMapper::get_country_uid_list_collection_name())->find(array('server_id'=>$server_id),array('uid'=>true,'server_id'=>true,'rank'=>true));
    if($_data->count()){
        foreach($_data as $data){
            if($data['server_id'] != $server_id) continue;
            if($data['uid']){
                $suid = explode("_",$data['uid']);
                $suid = end($suid);
                list($player, $ret) = Player::instance($suid);
                $temp_player_tmp_backpack_handle = $player->get_player_class_handle('tmpbackpack');
                if($player){
                    $bonus_list = array();
                    if(isset($bonus[$data['rank']])){
                        foreach($bonus[$data['rank']]['bonus'] as $bval){
                            $temp_player_tmp_backpack_handle->add_item($bval['id'], $bval['number'], 'country_bonus');
                        }
                    }
                }
                //如果此人第一，将起加入到当天国战中
                if($data['rank'] == 1){
                    $player_country_handle = $player->get_player_class_handle('country');
                    $times = date('Ymd',strtotime($player_country_handle->_counrty_week_str[Player_Const::COUNTRY_BATTLE_WEEK],NOWTIME));
                    $userinfo = $player_country_handle->get_country_user_list(array('uid'=>$data['uid']));
                    $userinfo = $userinfo[0];
                    $userinfo['player_detail'] = $player_country_handle->player_detail($data['uid']);
                    $country_data = $_country_handle->use_collection(NameMapper::get_country_info_collection_name())->update(array('times'=>(string)$times),array('$set'=>array('top'=>serialize($userinfo),'status'=>1)));
					Logger::error('$times:'.$times.'top:'.serialize($userinfo));
					echo date('Y-m-d H:i:s'),'$times:'.$times;
                    $lasttimes = date('Ymd',strtotime("last ".$player_country_handle->_counrty_week_str[Player_Const::COUNTRY_BATTLE_WEEK],NOWTIME));
                    $_country_handle->use_collection(NameMapper::get_country_info_collection_name())->update(array('times'=>(string)$lasttimes),array('$set'=>array('top'=>array())));
					Logger::error('$lasttimes:'.$lasttimes);
					echo '$lasttimes:'.$lasttimes;
                }
            }
        }
    }else{
    	echo 'error 1',PHP_EOL;
    }
}
echo date("Y-m-d H:i:s") . "|cron_country_bonus end \n";