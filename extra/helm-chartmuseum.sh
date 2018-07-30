#!/bin/bash

echo "$ helm version --client --short"
helm version --client --short

echo "$ helm init --client-only"
helm init --client-only

CHARTMUSEUM=$(kubectl get ing -n ${1:-devops} -o wide | grep chartmuseum | awk '{print $2}')

if [ ! -z ${CHARTMUSEUM} ]; then
    echo "$ helm repo add chartmuseum https://${CHARTMUSEUM}"
    helm repo add chartmuseum https://${CHARTMUSEUM}
fi

echo "$ helm repo list"
helm repo list

echo "$ helm repo update"
helm repo update

PLUGIN=$(helm plugin list | grep push | wc -l | xargs)

if [ "${PLUGIN}" == "0" ]; then
    echo "$ helm plugin install https://github.com/chartmuseum/helm-push"
    helm plugin install https://github.com/chartmuseum/helm-push
fi

echo "$ helm plugin list"
helm plugin list
