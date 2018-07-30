#!/bin/bash

JENKINS=$(kubectl get ing -n ${1:-devops} -o wide | grep jenkins | awk '{print $2}')

CHARTMUSEUM=$(kubectl get ing -n ${1:-devops} -o wide | grep chartmuseum | awk '{print $2}')

REGISTRY=$(kubectl get ing -n ${1:-devops} -o wide | grep docker-registry | awk '{print $2}')

NEXUS=$(kubectl get ing -n ${1:-devops} -o wide | grep sonatype-nexus | awk '{print $2}')

BASE_DOMAIN=${JENKINS:$(expr index $JENKINS \.)}
