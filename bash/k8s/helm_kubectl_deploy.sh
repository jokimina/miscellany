#!/bin/bash
source ~/.bashrc
set -x 
PHASE=testing
UPDATE_TIMEOUT=180s
LabelSelector="env=${PHASE},release=${JOB_BASE_NAME}"

cd $WORKSPACE
if [ x"$JOB_BASE_NAME" != x"sc-loan" ];then
    git tag ${BUILD_NUMBER} && git push --tags
fi

helm get ${JOB_BASE_NAME} &> /dev/null
if [ $? -eq 0 ];then
	deploymentName=$(kubectl get deployment  -l ${LabelSelector} -o go-template --template='{{range .items}}{{ .metadata.name}}{{end}}')
    [ -z $deploymentName ] && exit 500
    
    OLD_IMAGE=$(kubectl get deployment ${deploymentName} -o go-template --template='{{range .spec.template.spec.containers }}{{printf "%s" .image}}{{end}}')
	NEW_IMAGE=$(echo $OLD_IMAGE | sed -r "s/:.*/:${BUILD_NUMBER}/")
	kubectl set image deployments ${deploymentName} *=${NEW_IMAGE}
	kubectl label deployment ${deploymentName} chart=${JOB_BASE_NAME}-${BUILD_NUMBER} --overwrite
	kubectl label deployment ${deploymentName} imageTag=${BUILD_NUMBER} --overwrite
	timeout --signal SIGKILL ${UPDATE_TIMEOUT} kubectl rollout status deployment ${deploymentName}
    if [ $? -ne 0 ];then
    	echo "################# Update timeout， rollback!!!!!"
        samplePod=$(kubectl get po -l ${LabelSelector} | awk 'NR>1{print $1;exit}')
        kubectl logs --tail=100 ${samplePod}
        kubectl rollout undo deployment  ${deploymentName}
        exit 500
    fi
else
  while true
  do
    DEBUG_PORT=$(expr 30000 + $RANDOM % 2767)
    if ! kubectl get  svc -n kube-system nginx-ingress-lb  --template={{.spec.ports}}| grep -qrn $DEBUG_PORT  ;then
        break
    fi
    sleep 1s
  done
  echo ${JOB_BASE_NAME}
  helm install -n test --debug --dry-run --set "imageTag=${BUILD_NUMBER},appName=${JOB_BASE_NAME},debugPort=${DEBUG_PORT}" wesd/tomcat\
  | awk '/COMPUTED VALUES/{F=1;next}NF==0{F=0}F' | helm install --debug  -f - -n ${JOB_BASE_NAME} wesd/tomcat 
  [ $? -ne 0 ] && exit 500
  echo "## Patch ingress tcp-services port config "
  kubectl patch -n kube-system cm tcp-services  --patch '{"data":{"'${DEBUG_PORT}'": "default/'${JOB_BASE_NAME}'0debug:'${DEBUG_PORT}'"}}'
    
  echo "## Patch nginx-ingress-lb port listener config"
  kubectl patch -n kube-system svc nginx-ingress-lb  --patch '{"spec":{"ports":[{"name":"'${JOB_BASE_NAME}'0debug","port": '${DEBUG_PORT}', "protocol":"TCP", "targetPort": '${DEBUG_PORT}'}]}}'
fi
