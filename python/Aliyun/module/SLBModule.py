# coding: utf-8
import sys,os
import json
sys.path.append(os.path.abspath(".."))
from aliyunsdkcore import client
from aliyunsdkslb.request.v20160520 import (
                                            DescribeLoadBalancersRequest,
                                            DescribeHealthStatusRequest,
                                            SetBackendServersRequest
                                           )
from config_aliyun import config


class ApiSlbException(Exception):
    pass

class ApiNameMapper(object):
    """ short name of AliyunApis """
    get_all = getattr(DescribeLoadBalancersRequest,'DescribeLoadBalancersRequest')()
    get_health = getattr(DescribeHealthStatusRequest,'DescribeHealthStatusRequest')()
    set_back_servers = getattr(SetBackendServersRequest, 'SetBackendServersRequest')()

class SLBInstance(object):
    """ Front listen """
    def __init__(self):
        pass

class BackendServerInstance(object):
    def __init__(self):
        pass

class SLBRequest(object):

    def __init__(self,**config):
        self.AccessKey = config.get('AccessKey')
        self.AccessSecret = config.get('AccessSecret')
        self.RegionId = config.get('RegionId')
        self.request = None
        self.api_name = None
        self.result = None

        self.client = client.AcsClient(self.AccessKey,self.AccessSecret,self.RegionId)



    def __str__(self):
        return "AccessKey={},AccessSecret={},RegionId={},request={}".format(self.AccessKey,self.AccessSecret,self.RegionId,self.request)

    __repr__ = __str__

    @property
    def apis(self):
        """ show support apis """
        return filter(lambda x:not x.startswith('__'),dir(ApiNameMapper))

    def set_request_api(self, api_name):
        self.api_name = api_name

    def _request(self):
        if self.api_name:
            self.request = getattr(ApiNameMapper,self.api_name)
        else:
            raise(ApiSlbException,"call set_request_api() first, print cls.apis to show support apis.")

        if not self.request:
            raise(ApiSlbException,"Undefind api !")

        self.request.set_accept_format('json')

    def _do_action(self):
        self.result = self.client.do_action(self.request)


    def get_slbs(self):
        self.set_request_api('get_all')
        self._request()
        self._do_action()
        return json.loads(self.result)

    def get_back_server_health_status(self,LoadBalancerId):
        self.set_request_api('get_health')
        self._request()
        self.request.set_LoadBalancerId = LoadBalancerId
        self._do_action
        return json.loads(self.result)


if __name__ == '__main__':
    slb = SLBRequest(**config)
