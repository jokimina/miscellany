#!/usr/bin/env python
#-*- coding:utf-8 -*-
import urllib2
import sys
import json
import re
import ConfigParser

reload(sys)
sys.setdefaultencoding('utf-8')


def requestJson(url, values):
    data = json.dumps(values)
    #print url
    req = urllib2.Request(url, data, {'Content-Type': 'application/json-rpc'})
    response = urllib2.urlopen(req, data)
    output = json.loads(response.read())
    try:
        message = output['result']
    except:
        message = output['error']['data']
        print message
        quit()

    return output['result']


def authenticate(url, username, password):
    values = {'jsonrpc': '2.0',
              'method': 'user.login',
              'params': {
                  'user': username,
                  'password': password
              },
              'id': '0'
              }
    idvalue = requestJson(url, values)
    return idvalue


def get_web_scenario(zabbix_url, auth):
    host_list = []
    values = {'jsonrpc': '2.0',
              'method': 'httptest.get',
              "params": {
                  "output": "extend",
                  "selectSteps": "extend",
                  "httptestids": "41"
              },
              'auth': auth,
              'id': '1'
              }
    output = requestJson(zabbix_url, values)
    return output


def update_web_scenario(zabbix_url, auth, new_url):
    values = {
        "jsonrpc": "2.0",
        "method": "httptest.update",
        "params": {
                  "httptestid": "41",
                  # "status": 0
            "steps": [
             {
                 "name": "Gintama CDN_Url Status",
                 "url": new_url,
                 "status_codes": 200,
                 "no": 1
             }
            ]
        },
        "auth": auth,
        "id": 1
    }
    re_output = requestJson(zabbix_url, values)
    return re_output


def get_check_url(base_url, platform, File, hotFile):
    cf = ConfigParser.ConfigParser()
    cf.read(File)
    ver = cf.get('base', 'service.version')
    # 获取热版本号
    with open(hotFile) as f:
        hot_ver = f.readline().split()[-1]
    check_url = '%s/%s/%s/check_file.json' % (
        base_url, ver, hot_ver)
    return check_url


if __name__ == '__main__':
    platform = sys.argv[1]
    File = '/data/gintama_app/%s/game_code/config/%s/config.ini' % (platform,platform)
    hotFile = '/data/gintama_app/%s/game_code/config/%s/version.ini' % (platform,platform)
    base_url = 'http://gmcdn.youxi021.com/gintama/%s' % platform
    url = get_check_url(base_url, platform, File, hotFile)

    zabbix_url = 'http://zabbix.jidongnet.com/api_jsonrpc.php'
    username = 'Admin'
    password = 'jidongzabbixserver'
    auth = authenticate(zabbix_url, username, password)

    try:
        current_url = get_web_scenario(zabbix_url, auth)[0]['steps'][0]['url']
    except Exception, e:
        sys.exit('未获取到检测地址..清检查设置')

    print '正在检测版本：%s' % current_url
    if cmp(url, current_url):
        print '版本发生变动,更新至：%s' % url
        res = update_web_scenario(zabbix_url, auth, url)
        if not cmp(url, current_url):
            print '更新失败，正确地址：%s,\n\t   当前检测地址：%s' % (url, current_url)
        else:
            print '更新成功 当前检测地址：%s' % url
    else:
        print '版本没有变动...... 退出！'
    # print get_web_scenario(zabbix_url, auth)
    current_url = get_web_scenario(zabbix_url, auth)[0]['steps'][0]['url']
