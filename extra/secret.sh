#!/bin/bash

NAME=${1:-sample}
NAMESPACE=${2:-devops}

mkdir -p ~/.ssh

echo "Host *" > ~/.ssh/config
echo "    StrictHostKeyChecking no" >> ~/.ssh/config

kubectl get secret ${NAME} -n ${NAMESPACE} -o yaml | grep ssh-privatekey | awk '{print $2}' | base64 --decode > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

echo "" > ~/.ssh/known_hosts
