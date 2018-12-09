<?php
set_time_limit(0);
define('ROOT', dirname(__dir__));
include  ROOT . '/include/common.php';

$week = date('w');
$nowtime = time() + 1800;
$difftime = 259200;

$logdir = __dir__. '/logs/'.date('Ym'). '/';
!is_dir($logdir) && mkdir($logdir, 0755, true);
$logfile = $logdir. date('Ymd'). '.log';

//if ($week != "6")
//{/
	//exit("run time error!!!!");
//}

$redis_handle = RedisFactory::get();
$system_rank_handle = SystemRank::instance();
$lastSendDate = $redis_handle->get(NameMapper::get_arena_challenge_week_bonus_time_redis_key());
if (empty($lastSendDate))
{
	//$init_date = $system_rank_handle::get_current_week_6_day();
    $init_data = date("Y-m-d", strtotime("- 3 day"));
	$redis_handle->set(NameMapper::get_arena_challenge_week_bonus_time_redis_key(), $init_data);
	$lastSendDate = $init_date;
}
$lastSendDateTime = strtotime($lastSendDate. ' 20:00:00');
if ( $nowtime - $lastSendDateTime < $difftime)
{
	exit("run time error!!!!");
}

error_log("\r\n start send bonus time:". date("Y-m-d H:i:s"), 3, $logfile);
$last_rank_list = $system_rank_handle->get_full_challenge_list();
$rank_count = count($last_rank_list);
error_log("\r\n rank_list:". print_r($last_rank_list, true), 3, $logfile);

if ($rank_count > 1)
{
	//Backup
	error_log("\r\n rank_content:". json_encode($last_rank_list), 3, $logfile);
    $redis_handle->hMset(NameMapper::get_arena_challenge_week_bonus_history_redis_key(), $last_rank_list);
	$backup_challenge_rank_list_expire_result = $redis_handle->expire(NameMapper::get_arena_challenge_week_bonus_history_redis_key(), Player_Const::ARENA_CHALLENGE_WEEK_RANK_BONUS_HISTORY_EXPIRE);
	
	//发放竞技场Challenge前500名奖励物品
	$current_challenge_week_bonus_config = $system_rank_handle->get_current_challenge_week_bonus_config();
	foreach($last_rank_list as $temp_rank => $temp_uid)
	{

		$temp_rank = $temp_rank+1;
		//Rank 1 => Celebrity
		if ($temp_rank == 1){
			$celebrity_player = $redis_handle->set(NameMapper::get_arena_challenge_week_celebrity_redis_key(), $temp_uid);
		}
		
		$temp_bonus = $system_rank_handle->get_current_challenge_week_bonus_data($temp_rank, $current_challenge_week_bonus_config);
		list($temp_player_handle, $instance_failure_message) = Player::make($temp_uid);

		if ($temp_player_handle)
		{
			$temp_player_tmp_backpack_handle = $temp_player_handle->get_player_class_handle('tmpbackpack');
			$bonus = array();
			foreach($temp_bonus as $bonus_data)
			{
				$bonus[] = array('item' => $bonus_data['id'], 'number' => $bonus_data['number']);
				list($add_item_result, $err_msg) = $temp_player_tmp_backpack_handle->add_item($bonus_data['id'], $bonus_data['number'], 'challengeweek:'+ $temp_rank);
			}
			PlayerMessage::add_message($temp_uid, 14, array('battlerank' => $temp_rank));
			error_log("\r\n user:{$tmp_uid}, rank:{$temp_rank}, bonus:".json_encode($bonus), 3, $logfile);
		}
	}
}

//修改本周竞技场Challenge前N名奖励物品配置 redis => arena_challenge_week_bonus_index
$system_rank_handle->set_current_challenge_week_bonus_config();

//update last challenge week rank bonus time
$redis_handle->set(NameMapper::get_arena_challenge_week_bonus_time_redis_key(), date('Y-m-d',time()));
error_log("\r\n end send bonus time:". date("Y-m-d H:i:s"), 3, $logfile);
