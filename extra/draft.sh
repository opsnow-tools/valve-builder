#!/bin/bash

REGISTRY=$(kubectl get ing -n devops -o wide | grep docker-registry | awk '{print $2}')

draft version --short

draft init

draft config set registry $REGISTRY
draft config list
