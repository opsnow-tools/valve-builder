#!/bin/bash

echo "$ helm version"
helm version

echo "$ helm init --client-only"
helm init --client-only

CHARTMUSEUM=$(cat ${HOME}/CHARTMUSEUM)

if [ ! -z ${CHARTMUSEUM} ]; then
    echo "$ helm repo add chartmuseum https://${CHARTMUSEUM}"
    helm repo add chartmuseum https://${CHARTMUSEUM}
fi

echo "$ helm repo list"
helm repo list

echo "$ helm repo update"
helm repo update

PLUGIN=$(helm plugin list | grep push | wc -l | xargs)

if [ "x${PLUGIN}" == "x0" ]; then
    echo "$ helm plugin install https://github.com/chartmuseum/helm-push"
    helm plugin install https://github.com/chartmuseum/helm-push
fi

echo "$ helm plugin list"
helm plugin list
