#!/bin/bash

NAMESPACE=${1:-devops}

REGISTRY=$(kubectl get ing -n ${NAMESPACE} -o wide | grep docker-registry | awk '{print $2}')

draft config set registry ${REGISTRY}
