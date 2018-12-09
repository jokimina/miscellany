#!/bin/bash
kubectl_indonesia="kubectl --kubeconfig=$HOME/.kube/k8s-indonesia/config -n platform"
kubectl_platform="kubectl --kubeconfig=$HOME/.kube/k8s-platform/config"

indonesia_deploy_list=$($kubectl_indonesia get deployment -o go-template --template='{{range .items}}{{ println .metadata.name}}{{end}}')
platform_deploy_list=$($kubectl_platform get deployment -o go-template --template='{{range .items}}{{ println .metadata.name}}{{end}}')
common_deploy=$(echo "${indonesia_deploy_list}${platform_deploy_list}" | grep -vP 'ceres|eureka|mars-'  | sort | uniq -c | awk '$1==2{print $NF}')

#indonesia_image_list=$(echo $common_deploy | tr " " "\n" | xargs -i $kubectl_indonesia get deployment {} -o go-template --template='{{range .spec.template.spec.containers }}{{println .image}}{{end}}')
#platform_image_list=$(echo $common_deploy | tr " " "\n" | xargs -i $kubectl_platform get deployment {} -o go-template --template='{{range .spec.template.spec.containers }}{{println .image}}{{end}}')
indonesia_image_list=$($kubectl_indonesia get deployment $common_deploy -o go-template --template='{{range .items}}{{range .spec.template.spec.containers }}{{println .image}}{{end}}{{end}}')
platform_image_list=$($kubectl_platform get deployment $common_deploy -o go-template --template='{{range .items}}{{range .spec.template.spec.containers }}{{println .image}}{{end}}{{end}}')

diff -y <(echo $indonesia_image_list| tr " " "\n"|awk -F/ '{print $NF}') <(echo $platform_image_list| tr " " "\n"|awk -F/ '{print $NF}')
