#!/bin/bash

echo "$ draft version --short"
draft version --short

echo "$ draft init"
draft init

# REGISTRY=$(kubectl get ing -n ${1:-devops} -o wide | grep docker-registry | awk '{print $2}')

# if [ ! -z ${REGISTRY} ]; then
#     echo "$ draft config set registry ${REGISTRY}"
#     draft config set registry ${REGISTRY}
# fi
