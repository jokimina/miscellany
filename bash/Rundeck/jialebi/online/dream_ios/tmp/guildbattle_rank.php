<?php

require __DIR__ . '/common.php';
include  ROOT . '/include/common.php';

$redis_handle = RedisModel::instance();

$date_fmt = date('Y', time()) . date('W');
$log_info = $redis_handle->init('log_award_guildbattle', 'public')->get_hashes(); // 查询已发奖期
if ($log_info[$date_fmt]) {
    echo '已发奖';die;
}

// 公会战积分排名发奖
$gamecfg_handle = HashCfg::make('gamecfg');
$guildbattle_awardcfg_info = $gamecfg_handle->get_by_key('guildbattle_award');
$guild_awardcfg_info = $guildbattle_awardcfg_info['guild_award'];

$guildbattle_handle = Guildbattle::make();
$guild_rank_info = $guildbattle_handle->get_rank_list($date_fmt);
if (!empty($guild_rank_info)) {
    $credits = array();
    foreach($guild_rank_info as $key => $rank)
    {
        $credits[$key] = $rank['credit'];
    }
    array_multisort($credits, SORT_DESC, $guild_rank_info);
}


// 本服公会排名数据
$server_id = Application::$configs['server']['server_id'];
$this_rank_info = array();
foreach ($guild_rank_info as $key => $value) {
    if ($value['server_id'] == $server_id) {
        $this_rank_info[($key+1)] = $value;
    }
}
$res = array();
foreach ($guild_awardcfg_info as $vcfg) {
    foreach ($this_rank_info as $rank => $v) {
        if ($rank >= $vcfg['range'][0] && $rank <= $vcfg['range'][1]) {
            $res[$v['guild_id']] = $vcfg['award_list'];
            $guild_ranks[$v['guild_id']] = $rank;
        }
    }   
}
//发奖
if (!empty($res)) {
    $guild_handle = Guild::make();
    foreach ($res as $gid => $award_list) {
        echo $gid . ' ' . $guild_ranks[$gid] . "\n";
        $rids = $guild_handle->get_guild_member_ids($gid); // 公会成员ID
        if (!empty($rids)) {
            foreach ($rids as $rank => $rid) {
                $role_handle = Role::make($rid);
                $award_handle = $role_handle->get_role_class_handle('award');
                $award_handle->execute_award($award_list);

                $cash = $award_list[1]['num'];
                $copper = $award_list[0]['num'];
                $msg_data = array(
                    'guild_battle_rank' => $guild_ranks[$gid],
                    'cash' => $cash,
                    'copper' => $copper,
                );
                RoleMessage::add_message($rid, 47, $msg_data);

                echo $rid . "\n";
            }
        }
    }
}
// 记录发奖期数
$log_data = array(
    $date_fmt => 1,
);
$redis_handle->init('log_award_guildbattle', 'public')->update_hashes($log_data);
echo 'ok';die;