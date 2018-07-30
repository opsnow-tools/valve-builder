#!/bin/bash

CHARTMUSEUM=$(kubectl get ing -n ${1:-devops} -o wide | grep chartmuseum | awk '{print $2}')

helm repo add chartmuseum https://${CHARTMUSEUM}
