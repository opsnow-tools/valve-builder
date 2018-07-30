#!/bin/bash

REGISTRY=$(kubectl get ing -n ${1:-devops} -o wide | grep docker-registry | awk '{print $2}')

draft config set registry ${REGISTRY}