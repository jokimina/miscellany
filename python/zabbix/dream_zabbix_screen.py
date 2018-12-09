#!/usr/bin/env python
import urllib2
import sys
import json
import argparse
import re


def requestJson(url, values):
    data = json.dumps(values)
    req = urllib2.Request(url, data, {'Content-Type': 'application/json-rpc'})
    response = urllib2.urlopen(req, data)
    output =:
        message = output['error']['data'] json.loads(response.read())
    #    print output
    try:
        message = output['result']
    except
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


def getHosts(groupname, url, auth):
    host_list = []
    values = {'jsonrpc': '2.0',
              'method': 'hostgroup.get',
              'params': {
                  'output': 'extend',
                  'filter': {
                      'name': groupname
                  },

                  'selectHosts': ['hostid', 'host'],
              },
              'auth': auth,
              'id': '2'
              }
    output = requestJson(url, values)
    #    print output
    for host in output[0]['hosts']:
        host_list.append(host['hostid'])
    return host_list


def getTemplateids(url, template_name, auth):
    values = ({'jsonrpc': '2.0',
               'method': 'template.get',
               'params': {
                   'output': ['host', 'templateid'],
                   'filter': {
                       'host': template_name,
                   },
               },
               'auth': auth,
               'id': 3,
               })
    output = requestJson(url, values)
    print output
    return output[0]['templateid']


def getGraphs(host_list, url, auth, graphtype=0):
    if (graphtype == 0):
        selecttype = ['graphid']
        select = 'selectGraphs'
    if (graphtype == 1):
        selecttype = ['itemid', 'value_type']
        select = 'selectItems'
    values = ({'jsonrpc': '2.0',
               'method': 'graph.get',
               'params': {
                   'output': ['graphid', 'name'],
                   select: [selecttype, 'name'],
                   'hostids': host_list,
                   'sortfield': 'name',

               },
               'auth': auth,
               'id': 3
               })
    output = requestJson(url, values)
    # print output
    android_redis_memory_output = []
    android_redis_stats_output = []
    ios_redis_memory_output = []
    ios_redis_stats_output = []
    for i in output:
        # print i
        if i['name'].startswith('Redis_Memory 65'):
            android_redis_memory_output.append(i)
        elif i['name'].startswith('Redis_Memory 68'):
            ios_redis_memory_output.append(i)
        elif i['name'].startswith('Redis_Stats 65'):
            android_redis_stats_output.append(i)
        elif i['name'].startswith('Redis_Stats 68'):
            ios_redis_stats_output.append(i)
    return android_redis_memory_output, ios_redis_memory_output, android_redis_stats_output, ios_redis_stats_output


def getGraphids(output, columns, graphtype=0, dynamic=0):
    print output
    bb = sorted(output, key=lambda x: x['graphid'])
    print bb
    graphs = []
    if (graphtype == 0):
        for i in bb:
            print i
            graphs.append(i['graphid'])
    if (graphtype == 1):
        for i in bb:
            if int(i['value_type']) in (0, 3):
                graphs.append(i['itemid'])

    print graphs

    graph_list = []
    x = 0
    y = 0
    for graph in graphs:
        #        print "x is " + str(x)
        #        print "y is " + str(y)
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
        #        print "**** X IS ***", x

        if x == int(columns):
            x = 0
            y += 1
        #        print "**** Y IS ***",y
        #    print graph_list
    return graph_list


def screenCreate(url, auth, screen_name, graphids, columns):
    columns = int(columns)

    #    print "******"
    #    print  len(graphids)
    #    print "******"
    if len(graphids) % columns == 0:
        vsize = len(graphids) / columns
    else:
        vsize = (len(graphids) / columns) + 1

    print "*****VSIZE IS*********", vsize
    values0 = {
        "jsonrpc": "2.0",
        "method": "screen.get",
        "params": {
            "output": "extend",
            "filter": {
                "name": screen_name,
            }
        },
        "auth": auth,
        "id": 2
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
    output0 = requestJson(url, values0)
    print output0
    if output0 == []:
        print "The Given Screen Name Not Exists"
        print "Creating Screen %s" % screen_name
        for i in graphids:
            values['params']['screenitems'].append(i)
        output = requestJson(url, values)
    else:
        print "The Given Screen Name Already Exists"
        update_screenid = output0[0]["screenid"]
        print update_screenid
        print "Updating Screen Name %s  Screen ID %s" % (screen_name, update_screenid)
        values1 = {
            "jsonrpc": "2.0",
            "method": "screen.update",
            "params": {
                "screenid": update_screenid,
                "screenitems": [],
                "hsize": columns,
                "vsize": vsize,
            },
            "auth": auth,
            "id": 2
        }
        output1 = requestJson(url, values1)
        print output1
        print "Updating  Screen Name %s" % screen_name
        for i in graphids:
            values1['params']['screenitems'].append(i)
        output = requestJson(url, values1)


def main():
    url = 'http://zabbix.jidongnet.com/api_jsonrpc.php'
    username = 'Admin'
    password = 'jidongzabbixserver'
    columns = 2
    auth = authenticate(url, username, password)
    host_list = getHosts(groupname, url, auth)
    #    print host_list
    output1, output2, output3, output4 = getGraphs(host_list, url, auth)
    #    print output1
    #    print output2
    #    print output3
    #    print output4
    graphids1 = getGraphids(output1, columns)
    #    print graphids1
    screenname1 = 'Dream_Android_Redis_Used_Memory'
    screenCreate(url, auth, screenname1, graphids1, columns)

    graphids2 = getGraphids(output2, columns)
    screenname2 = 'Dream_IOS_Redis_Used_Memory'
    screenCreate(url, auth, screenname2, graphids2, columns)

    graphids3 = getGraphids(output3, columns)
    screenname3 = 'Dream_Android_Redis_Stats'
    screenCreate(url, auth, screenname3, graphids3, columns)
    #
    graphids4 = getGraphids(output4, columns)
    screenname4 = 'Dream_IOS_Redis_Stats'
    screenCreate(url, auth, screenname4, graphids4, columns)


if __name__ == '__main__':
    #    parser = argparse.ArgumentParser(description='Create Zabbix screen from all of a host Items or Graphs.')
    #    parser.add_argument('-G', dest='graphname', nargs='+',metavar=('grah name'),
    #                        help='Zabbix Host Graph to create screen from')
    #    parser.add_argument('-H', dest='hostname', nargs='+',metavar=('10.19.111.145'),
    #                        help='Zabbix Host to create screen from')
    #    parser.add_argument('-g', dest='groupname', nargs='+',metavar=('linux server'),
    #                        help='Zabbix Group to create screen from')
    #    parser.add_argument('-n', dest='screenname', type=str,
    #                        help='Screen name in Zabbix.  Put quotes around it if you want spaces in the name.')
    #    parser.add_argument('-c', dest='columns', type=int,
    #                        help='number of columns in the screen')
    #    args = parser.parse_args()
    #    print args
    #    hostname = args.hostname
    groupname = 'Disney Servers'
    #    screenname = args.screenname
    #    columns = args.columns
    #    graphname = args.graphname
    #    if columns is None:
    #        columns = len(graphname)
    #    print columns
    main()
