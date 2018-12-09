<?php

require __DIR__ . '/common.php';
include  ROOT . '/include/common.php';

$redis_handle = RedisModel::instance();


// 删除参战数据
$guildbattle_key = 'guildbattle_data';
$redis_handle->init($guildbattle_key, 'guildbattle')->del_key_one();
$detail_key = 'guildbattle_data_detail_' . Application::$configs['server']['server_id'];
$redis_handle->init($detail_key, 'guildbattle')->del_key_one();

$a = memory_get_usage();
echo "use memory " . round($a/1048576,2) . " MB\n";

echo "clear all sea ok.\n";
?>
