# 自动补全:
```
yum -y install bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
```
# 添加镜像仓库认证
```
kubectl -n $NAMESPACE create secret docker-registry $KEYNAME \
--docker-server=$DOCKER_REGISTRY_SERVER \
--docker-username=$DOCKER_USER \
--docker-password=$DOCKER_PASSWORD \
--docker-email=$DOCKER_EMAIL
echo "------------ create k8s-user secret ----------------"
kubectl get secret $KEYNAME --output="jsonpath={.data.\.dockerconfigjson}" | base64 -d
echo "------------ add k8s-user serviceaccount ----------------"
kubectl -n $NAMESPACE patch serviceaccount default -p '{"imagePullSecrets": [{"name": "k8s-user"}]}'
```
# 获取集群内部service&pod网段
```
ps -ef | grep -Po 'cluster-cidr\S+\s|service-cluster-ip-range\S+\s'
```
# 获取集群/组件状态
```
kubectl get componentstatus
kubectl cluster-info
```
# 获取kubelet状态
```
systemctl status kubelet
journalctl -xefu kubelet
```
# 更新istio流量拦截网段
```
helm template install/kubernetes/helm/istio --set global.proxy.includeIPRanges="10.1.0.0/16\,10.2.0.0/20" -x templates/sidecar-injector-configmap.yaml | kubectl apply -f -
```
# istio 开启自动注入
```
kubectl label namespace default istio-injection=enabled
```
# istio替换现有deploy, 注入sidercar
```
istioctl kube-inject -f <(kubectl get deploy xxx -o yaml) | kubectl replace -f -
```
# 重启pod(无法直接重启, 删除或者replace pod可以达到重启效果, 或者进入容器/cashbus/tomcat/restart.sh)
```
kubectl delete po -l app=sc-tag

kubectl get pod logtail-ds-698m5 -n kube-system -o yaml | kubectl replace --force -f -
```
# 转发pod流量到kubectl运行节点上
```
# kiali
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
# grafana
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &
# prometheus
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 &
# service Graph
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=servicegraph -o jsonpath='{.items[0].metadata.name}') 8088:8088 &
# jaeger-collector
kubectl -n istio-system port-forward $(kubectl -n istio-system get po -l app=tracing-on-sls,component=collector -o jsonpath='{.items[0].metadata.name}') 9411:9411&

```
# 停止应用所有pod 没法直接停止 可以 scale对应deployment为0达到效果
```
kubectl scale xx sc-contract-sc-xxx --replicas=0
```
# 命令行处理yaml
```
cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: simple
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /svc
        backend:
          serviceName: http-svc
          servicePort: 80
EOF
```

# 标记master可调度(不建议)

```
kubectl taint node -l node-role.kubernetes.io/master node-role.kubernetes.io/master=:PreferNoSchedule --overwrite
kubectl taint node -l node-role.kubernetes.io/master node-role.kubernetes.io/master-

```
# 标记节点不可调度

```
kubectl cordon node 
```

# helm手动安装
```
######### helm install
需要支持ipv6
/etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
$ sysctl -p
/etc/sysconfig/network
NETWORKING_IPV6=yes
$ service network restart
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
```

# helm  tiller自行升级  官方源被墙 国内连不上 这里用阿里镜像源

```
export TILLER_TAG=v2.9.1
kubectl --namespace=kube-system set image deployments/tiller-deploy tiller=registry-vpc.cn-beijing.aliyuncs.com/google_containers/tiller:$TILLER_TAG
```
# helm 自动补全
```
source <(helm completion bash)
```
# 获取pod异常终止前的状态
```
kubectl get pod -o go-template='{{range.status.containerStatuses}}{{"Container Name: "}}{{.name}}{{"\r\nLastState: "}}{{.lastState}}{{end}}' xxxxxxxx

```
# 删除node
```
转移节点正在运行的 resource
kubectl get no -o wide | awk '/NotReady/{print $1}' | xargs -i -t kubectl drain {} --ignore-daemonsets
删除
kubectl get no -o wide | awk '/NotReady/{print $1}' | xargs -i -t kubectl delete node {}
```
# 逐出节点上所有pod
```
kubectl drain cn-beijing.i-xxxxx --delete-local-data --ignore-daemonsets
```
# 批量打ingress controller标签 用作自动调度
```
kubectl get node | awk '!/master/{print $1}' |xargs -i -t kubectl label node {} node-role.kubernetes.io/ingress=true --overwrite
```
# 各种patch
```
patch configmap
kubectl patch -n kube-system cm tcp-services --patch '{"data":{"32218": "default/sc-xxx0debug:32219"}}'
patch serice
kubectl patch -n kube-system svc nginx-ingress-lb --patch '{"spec":{"ports":[{"name":"patch-test","port": 32222, "protocol":"TCP", "targetPort": 32222}]}}'
patch nodeSelector
kubectl patch deployment sc-demo-sc-demo -p '{"spec":{"template":{"spec":{"nodeSelector":{"env":"testing"}}}}}'
patch  readiness healthCheck  jsonpatch http://jsonpatch.com/ 
```
# patch healthCheck, JSON Patch, RFC 6902
```
kubectl patch deployment xxxx --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/readinessProbe",
    "value": {
        "failureThreshold": 1,
        "initialDelaySeconds": 30,
        "periodSeconds": 3,
        "successThreshold": 3,
        "httpGet": {
          "path": "/rest/healthCheck",
          "port": "app-port"
        },
        "timeoutSeconds": 1
      }
  }
]'

```

# 获取所有运行镜像 go-template示例
```
kubectl get deployment -o go-template --template='{{range .items}}{{range .spec.template.spec.containers }}{{printf "%s\n" .image}}{{end}}{{end}}'
kubectl get deployment -o go-template --template='{{range .items}}{{range .spec.template.spec.containers }}{{printf "%s\n" .image}}{{end}}{{end}}' | awk -F'[:/]' '{printf "    [\042%s\042]=\042%s\042\n",$(NF-1),$NF}'
```

# 删除istio相关crd(customresourcedefinition)
```
kubectl get crd | awk '/istio/{print $1}' | xargs -i kubectl delete crd {}
```

# 清空整个namespace(慎用)
```
kubectl -n istio-system delete all --all
```
# 强制更新 helm "no deployed release"状态的release，感觉还是比较鸡肋. 至今没找到好的办法处理 "no deployed release"
```
helm upgrade --force -i -f ack-istio-default.yaml ack-istio-default incubator/ack-istio
```
