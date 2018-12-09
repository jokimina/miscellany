var int_list = []
var pub_list = []
var eip_list = []
var num = 50
// 获取ECS的公网ip 和内网ip
$.each($("[ecs-instance-ip=''] [ng-hide='!item.internetIp']").slice(0,num),function(i,v){pub_list.push(v.innerText.replace(/\(公\)/g,""))})
$.each($("[ecs-instance-ip=''] [ng-hide='!item.intranetIp']").slice(0,num),function(i,v){int_list.push(v.innerText.replace(/\(内\)/g,""))})
$.each($("[ecs-instance-ip=''] [ng-hide='!item.eip']").slice(0,num),function(i,v){eip_list.push(v.innerText.replace(/\(弹性\)/g,""))})


//获取实例的私有ip
var pri_list = []
$.each($("[ecs-instance-ip=''] [ng-hide='!item.intranetIp']").slice(0,10),function(i,v){pri_list.push(v.innerText.replace(/\(私有\)/g,""))})

// 获取实例id
var hlist = []
var num = 100
$.each($("[item-property-update='hostname']").slice(0,num), function(i,v){hlist.push(/(aliyun-tooltip2=")(.*?)(")/.exec(v.innerHTML)[2])})
$.each($('[ui-sref="serverDetail.detail({instanceId:item.instanceId, regionId: item.regionId})"]').slice(0,num),function(i,v){hlist.push(v.text)})

//获取SLB实例白名单列表
l = []
$.each($('.entry .ng-binding'), (i,v)=> l.push(v.innerText))
l.join('|clone office\n')
