<?php
/**
 * 发送BI 进程  指定BI存在的redis位置启动即可.
 * 建议使用supervisord监控进程
 * @var string
 */
$rhost = '10.10.41.13';
$rport = 6380;
$rdb = 1;
$rpassword ='';
declare(ticks = 1);

$to_exit = false;
function work_exit() {
    global $to_exit;
    $to_exit = true;
}

pcntl_signal(SIGTERM, "work_exit");
pcntl_signal(SIGINT, "work_exit");
pcntl_signal(SIGUSR1, "work_exit");

//Logger::set_name("work");
//Logger::set_level(LOG_NOTICE);

echo "[" . date('Y-m-d H:i:s') . "]start to run track log\n";

$redis_handle = new Redis();

$success = $redis_handle->connect($rhost, $rport, 3);
if(!$success){
    error_log("\r\n track_log redis is fail",3,'/tmp/err_track_log.log');
   echo "track_log redis is fail";
     exit;
}
if($rpassword){
    $redis_handle->auth($rpassword);
}
$redis_handle->select($rdb);
$redis_bi_key = 'bi';

while(true) {
    if ($to_exit) {
        echo "[" . date('Y-m-d H:i:s') . "] track log quit for user end\n";
        break;
    }
    
    if ($redis_handle->llen($redis_bi_key) > 0) {
        $url = $redis_handle->rpop($redis_bi_key);
        if (!empty($url)){
            $result = curl($url);
            if ($result === false) {
                $redis_handle->lpush($redis_bi_key, $url);
            }
        }
    }

    //usleep(100000);
    usleep(1);
}

/**
     *
     * @param string $url
     * @param array $post_data
     * @param string $proxy
     * @param int $max_loop
     * @return mixed
     */
    function curl($url, $post_data = '', $proxy = '', $max_loop=1) {
        $ch = curl_init();

        $options = array(
            CURLOPT_USERAGENT      => "GameCurl",
            CURLOPT_TIMEOUT        => 10,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_URL            => $url,
            CURLOPT_FOLLOWLOCATION => true,
             CURLOPT_PROXY         => '',
            CURLOPT_HTTPHEADER     => array("Expect:")
        );

        //代理
        if ($proxy) {
            $options[CURLOPT_PROXY]     = $proxy;
            $options[CURLOPT_PROXYTYPE] = CURLPROXY_SOCKS5;
        }

        //post
        if ($post_data) {
            $options[CURLOPT_POST] = true;
            $options[CURLOPT_POSTFIELDS] = $post_data;
        }

        curl_setopt_array($ch, $options);
        $result = curl_exec($ch);
        if (false === $result || curl_errno($ch)) {
            $max_loop++;
            if ($max_loop <= 3) {
                $result = curl($url, $post_data, $proxy, $max_loop);
            }
        }
        curl_close($ch);

        return $result;
    }

