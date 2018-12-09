<?php

require __DIR__ . '/common.php';
include  ROOT . '/include/common.php';

$redis_handle = RedisModel::instance();

//获取玩家ids
$rids = Role::get_role_ids();

foreach ($rids as $rid) {

	$redis_key = 'rmodule_' . $rid;
	$redis_handle->init($redis_key, 'rdata')->del_hash_field('guildbattle');
    $redis_handle->init($redis_key, 'rdata')->del_hash_field('my_mercenary');
    $redis_handle->init($redis_key, 'rdata')->del_hash_field('mercenary_log');

	//设置卡牌状态
	$role_handle = Role::make($rid);
    $rcard_handle = $role_handle->get_role_class_handle('card');
    $rcard_handle->set_notice(false);
    $rcard_infos = $rcard_handle->get_rcard_infos();

    $is_update = false;
    foreach ($rcard_infos as $key => $value) {
    	if ($value['guildbattle_status'] == 1) {
    		$rcard_handle->set_update_info($value['id'], 'guildbattle_status', 0);
	    	$is_update = true;
    	}
    }

    if ($is_update) {
    	$rcard_handle->execute();
    }

    echo "clean role `{$rid}` ok.\n";

	Logger::clear();
}

// 删除参战数据
$guildbattle_key = 'guildbattle_data';
$redis_handle->init($guildbattle_key, 'guildbattle')->del_key_one();
$detail_key = 'guildbattle_data_detail_' . Application::$configs['server']['server_id'];
$redis_handle->init($detail_key, 'guildbattle')->del_key_one();

$a = memory_get_usage();
echo "use memory " . round($a/1048576,2) . " MB\n";

echo "clear all sea ok.\n";
?>