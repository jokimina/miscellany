#!/usr/bin/env python
import urllib2
import sys
import json
import argparse


def requestJson(url,values):        
    data = json.dumps(values)
    req = urllib2.Request(url, data, {'Content-Type': 'application/json-rpc'})
    response = urllib2.urlopen(req, data)
    output = json.loads(response.read())
#    print output
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
    idvalue = requestJson(url,values)
    return idvalue
 
def getHosts(groupname,url,auth):
    host_list = []
    values = {'jsonrpc': '2.0',
              'method': 'hostgroup.get',
              'params': {
                  'output': 'extend',
                  'filter': {
                      'name': groupname
                  },
 
                  'selectHosts' : ['hostid','host'],
              },
              'auth': auth,
              'id': '2'
              }
    output = requestJson(url,values)
    for host in output[0]['hosts']:
        host_list.append(host['hostid'])
    return host_list

def getHostgroups(url,auth):
    hostgroup_list = []
    values = {'jsonrpc' : '2.0',
              'method' :  'hostgroup.get',
              'params' :  {
                     'output' : ['groupid','name'],
                     'sortfield' : 'name',
                          },
              'auth' : auth,
              'id' : '2'
              }
 
    output = requestJson(url,values)
#    print output
    for hostgroup in output:
#        print hostgroup['name']
 
        if  hostgroup['name'].startswith(('Discovered','Templates','templates')) or hostgroup['name'].endswith(('Templates','templates')):
           print "Skip this group %s" %hostgroup['name']
        else:
           hostgroup_list.append(hostgroup['name'])
    return hostgroup_list
 
 
 



 
def getGraphs(host_list,name_list, url, auth, columns, graphtype=0 ,dynamic=0):
    if (graphtype == 0):
       selecttype = ['graphid']
       select = 'selectGraphs'
    if (graphtype == 1):
       selecttype = ['itemid', 'value_type']
       select = 'selectItems'
    values=({'jsonrpc' : '2.0',
             'method' : 'graph.get',
             'params' : {
                  'output' : ['graphid','name'],
                  select : [selecttype,'name'],
                  'hostids' : host_list,
                  'sortfield' : 'name',
                  'filter' : {
                         'name' : name_list,
 
                             },
                        },
             'auth' : auth,
             'id' : 3
              })
    output = requestJson(url,values)
    bb = sorted(output,key = lambda x:x['graphid'])
    graphs = []
    if (graphtype == 0):
        for i in bb:
            print i
            graphs.append(i['graphid'])
    if (graphtype == 1):
        for i in bb:
            if int(i['value_type']) in (0, 3):
               graphs.append(i['itemid'])
 
    graph_list = []
    x = 0
    y = 0
    for graph in graphs:
        print "x is " + str(x)
        print "y is " + str(y)
        graph_list.append({
            "resourcetype": graphtype,
            "resourceid": graph,
            "width": "500",
            "height": "200",
            "x": str(x),
            "y": str(y),
            "colspan": "0",
            "rowspan": "0",
            "elements": "0",
            "valign": "0",
            "halign": "0",
            "style": "0",
            "url": "",
            "dynamic": str(dynamic)
        })
        x += 1
#        print type(x)
#        print type(columns)
        if x == int(columns):
            x = 0
            y += 1
#    print graph_list
    return graph_list
     
def screenCreate(url, auth, screen_name, graphids, columns):
    columns = int(columns)
    if len(graphids) % columns == 0:
        vsize = len(graphids) / columns
    else:
        vsize = (len(graphids) / columns) + 1
         
    values0 = {
               "jsonrpc" : "2.0",
               "method"  : "screen.get",
               "params"  : {
                   "output" : "extend",
                   "filter" : {
                       "name" : screen_name,
                              }
                           },
               "auth" : auth,
               "id" : 2
               }
    values = {
              "jsonrpc": "2.0",
              "method": "screen.create",
              "params": {
                  "name": screen_name,
                  "hsize": columns,
                  "vsize": vsize,
                  "screenitems": []
              },
              "auth": auth,
              "id": 2
              }
    output0 = requestJson(url,values0)
    print output0
     
    if output0 == []:
       print "The Given Screen Name Not Exists"
       print "Creating Screen %s" %screen_name
       for i in graphids:
          values['params']['screenitems'].append(i)
       output = requestJson(url,values)
    else:
     
     
       print "The Given Screen Name Already Exists"
       update_screenid=output0[0]["screenid"]
       print update_screenid
       print "Updating Screen Name %s  Screen ID %s" %(screen_name,update_screenid)
       values1 = {
               "jsonrpc" : "2.0",
               "method"  : "screen.update",
               "params"  : {
                       "screenid" : update_screenid,
                       "screenitems": [],
                       "hsize": columns,
                       "vsize": vsize,
                           },
               "auth"    : auth,
               "id"      : 2
                 }
       output1 = requestJson(url,values1)
       print output1
       print "Updating  Screen Name %s" %screen_name
       for i in graphids:
          values1['params']['screenitems'].append(i)
       output = requestJson(url,values1)
 
def main():
    url = 'http://zabbix.jidongnet.com/api_jsonrpc.php'
    username = 'Admin'
    password = 'jidongzabbixserver'
    columns = 2
 
    graphname_list = ['CPU utilization','CPU load','Memory usage','Network traffic on eth0','Network traffic on eth1','Swap usage','CPU jumps']
     
    auth = authenticate(url, username, password)
    hostgroup_list = getHostgroups(url,auth)
    print hostgroup_list
     
    for groupname in hostgroup_list:
        print groupname
        host_list = getHosts(groupname,url,auth)
        print host_list
         
        for graphname in graphname_list:
            print graphname
            graph_ids = getGraphs(host_list,graphname, url, auth, columns)
            screenname = groupname + ' ' + graphname
            screenCreate(url, auth, screenname, graph_ids, columns)
if __name__ == '__main__':
    main()
