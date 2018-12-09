#!/usr/bin/env python
# -*- coding: utf-8 -*-

from sdk import UcloudApiClient
from config import *
import sys
import json

#实例化 API 句柄
'''
数据中心列表 Region :
北京BGP-A	cn-north-01	Bgp: BGP线路
北京BGP-B	cn-north-02	Bgp: BGP线路
北京BGP-C	cn-north-03	Bgp: BGP线路
华东双线	cn-east-01	Duplet: 双线, Unicom: 网通, Telecom: 电信
华南双线	cn-south-01	Duplet: 双线, Unicom: 网通, Telecom: 电信
亚太		hk-01		International: 国际线路
北美		us-west-01	International: 国际线路
'''

if __name__=='__main__':
    arg_length = len(sys.argv)
    Region = sys.argv[1]
    ApiClient = UcloudApiClient(base_url, public_key, private_key)
    Parameters={
                "Action":"DescribeUHostInstance",
                "Region": Region
               }
    response = ApiClient.get("/", Parameters);
    print json.dumps(response, sort_keys=True, indent=4, separators=(',', ': '))

