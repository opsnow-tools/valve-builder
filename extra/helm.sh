#!/bin/bash

CHARTMUSEUM=$(kubectl get ing -n devops -o wide | grep chartmuseum | awk '{print $2}')

helm version --client --short

helm init

helm list

helm repo add chartmuseum https://$CHARTMUSEUM
helm repo update
helm repo list

# helm plugin install https://github.com/chartmuseum/helm-push
helm plugin list
