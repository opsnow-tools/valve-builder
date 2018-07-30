#!/bin/bash

helm init --client-only

CHARTMUSEUM=$(kubectl get ing -n ${1:-devops} -o wide | grep chartmuseum | awk '{print $2}')

helm repo add chartmuseum https://${CHARTMUSEUM}

PLUGIN=$(helm plugin list | grep push | wc -l | xargs)

if [ "${PLUGIN}" == "0" ]; then
    helm plugin install https://github.com/chartmuseum/helm-push
fi
