#!/bin/bash

JENKINS=$(kubectl get ing -n ${1:-devops} -o wide | grep jenkins | awk '{print $2}')

BASE_DOMAIN=${JENKINS:$(expr index $JENKINS \.)}
