#!/bin/bash

JENKINS=$(kubectl get ing -n ${1:-devops} -o wide | grep jenkins | awk '{print $2}')
CHARTMUSEUM=$(kubectl get ing -n ${1:-devops} -o wide | grep chartmuseum | awk '{print $2}')
REGISTRY=$(kubectl get ing -n ${1:-devops} -o wide | grep docker-registry | awk '{print $2}')
NEXUS=$(kubectl get ing -n ${1:-devops} -o wide | grep sonatype-nexus | awk '{print $2}')

BASE_DOMAIN=${JENKINS:$(expr index $JENKINS \.)}

printf $JENKINS > /home/jenkins/JENKINS
printf $CHARTMUSEUM > /home/jenkins/CHARTMUSEUM
printf $REGISTRY > /home/jenkins/REGISTRY
printf $NEXUS > /home/jenkins/NEXUS

printf $BASE_DOMAIN > /home/jenkins/BASE_DOMAIN

echo "# BASE_DOMAIN: $(cat /home/jenkins/BASE_DOMAIN)"
echo "# JENKINS: $(cat /home/jenkins/JENKINS)"
echo "# CHARTMUSEUM: $(cat /home/jenkins/CHARTMUSEUM)"
echo "# REGISTRY: $(cat /home/jenkins/REGISTRY)"
echo "# NEXUS: $(cat /home/jenkins/NEXUS)"
