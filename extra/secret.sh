#!/bin/bash

NAME=${1:-sample}
NAMESPACE=${2:-devops}

mkdir -p /root/.ssh

echo "Host *" > /root/.ssh/config
echo "    StrictHostKeyChecking no" >> /root/.ssh/config

kubectl get secret ${NAME} -n ${NAMESPACE} -o yaml | grep ssh-privatekey | awk '{print $2}' | base64 --decode > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

echo "" > /root/.ssh/known_hosts
