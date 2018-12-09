<?php

$router = array(
	'apple' => array(
				'url' => 'http://zg-router.youxi021.com',
				'ver' => '1.7.1',
			),

	'kingnet' => array(
				'url' => 'http://router.zg.kingnet.com',
				'ver' =>'1.8.0'
			),
	'jp' => array(
				'url' => 'zg-jp-router.ucube.mobi',
				'ver' =>'1.4.0'
			),

	'kr' => array(
				'url' => 'http://zg-kr-router.kingnet.com',
				'ver' =>'1.6.0'
			),
);
$Monitor = new Monitor($router);
$Monitor->run();
$error_list = $Monitor->get_error();
if(!empty($error_list)) {
	echo implode("\r\n", $error_list);
	exit;
}
class Monitor {

	private $router_server = array();
	private $login_server  = array();
	private $game_server   = array();
	private $error_list    = array();
	private $user_info     = array();
	public function __construct($router_server) {
		$this->set_router($router_server);
		$this->user_info['email'] = 'wangdy@jidongnet.com';
		$this->user_info['password'] = 'robot123';
		$this->user_info['mac']     = "111111111111";
	}

	public function set_router($router_server) {
		$this->router_server = $router_server;
	}
	public function get_error() {
		return $this->error_list;
	}
	public function run(){
		$this->call_routre();
		$this->call_login();
		$this->call_game();
		return $this->get_error();
	}
	//call router return login_url
	private function call_routre() {
		if(empty($this->router_server)) {
			$this->error_list[] = "router list is empty";
			return false;
		}
		foreach ($this->router_server as $key => $value) {
			$result = json_decode($this->_cal_server($value['url'],array('ver'=>$value['ver'])),true);
			if(!isset($result['result']) || $result['result'] !== 1){
            	$this->error_list[] = "call router is error, error info , url:".$value['url'];
	        	continue;
	        }
	        $this->login_server[$key] = $result['data']['url'];
		}
	}
	//call login return game_url
	private function call_login() {
		if(empty($this->login_server)) {
			$this->error_list[] = "login list is empty";
			return false;
		}
		foreach ($this->login_server as $key => $login_url) {
			$result = json_decode($this->_cal_server($login_url . '/login.php', $this->user_info), true);
	        if($result['result'] == 0 && $result['data'] == 1){
	            //没有这个账号，需要注册
	            $register_result = json_decode($this->_cal_server($login_url . '/register.php', $this->user_info), true);
	            if($register_result['result'] == 1){
	                //注册成功，重新登录
	                $login_result = json_decode($this->_cal_server($login_url . '/login.php', $this->user_info), true);
	                if($login_result['result'] == 1){
	                    $server_list = $login_result['data']['game_server'];
	                }else{
	                	$this->error_list[] = "Register then login failed, url :".$login_url;
	                    continue;
	                }
	            }else{
	            	$this->error_list[] = "account has been register, url :".$login_url;
	                continue;
	            }
	        }else if($result['result'] == 1){
	            //登录成功
	            $server_list = $result['data']['game_server'];
	        }else{
	            $this->error_list[] = "get server list failed, url :".$login_url;
	            continue;   
	        }
	        $data = array();
	        foreach($server_list as $server){
	        	$this->game_server[$key]['server'][$server['server_id']] = $server; 
	        	$this->game_server[$key]['player_data'] = $result['data']['player_data']; 
	        }
		}
	}
	//call game return server_info
	private function call_game() {
		if(empty($this->game_server)) {
			$this->error_list[] = "game_server  list is error";
			return false;
		}
		foreach ($this->game_server as $key => $value) {
			foreach ($value['server'] as  $info) {
				$post_data['select_token'] =  $info['select_token'];
				$post_data['sns_url']      =  $this->login_server[$key];
				$post_data['player_data']  =  json_encode($value['player_data']);
				$result = json_decode($this->_cal_server($info['game_base_url'],$post_data),true);
				if($result['result'] !=1) {
					$this->error_list[] = "game_server is error ,url:".$info['game_base_url'];
					continue;
				}
			}
		}
	}
	private function _cal_server($url, $data) {
		$ch = curl_init();
        curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)");
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, TRUE);
        curl_setopt($ch, CURLOPT_POST, TRUE);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        $result = curl_exec($ch); // execute the curl command
        if (curl_errno($ch)) {
        	$this->error_list[] = "curl fetch failed,url:" . $url . ". error:". curl_error($ch);
        	return false;
        }
        $response = curl_getinfo($ch);
        if(empty($response) || $response['http_code'] != 200) {
        	$this->error_list[] = "curl fetch error,url:" . $url . ",response = ".json_encode($response); 
        	unset($response,$result);
        	return false;
        }
        curl_close($ch);
        return $result;
	}
}
