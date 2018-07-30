#!/bin/bash

NAMESPACE=${1:-devops}

CHARTMUSEUM=$(kubectl get ing -n ${NAMESPACE} -o wide | grep chartmuseum | awk '{print $2}')

helm repo add chartmuseum https://${CHARTMUSEUM}
