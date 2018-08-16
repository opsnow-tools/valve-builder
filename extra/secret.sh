#!/bin/bash

NAME=${1:-sample}
NAMESPACE=${2:-devops}

mkdir -p ~/.ssh
kubectl get secret ${NAME} -n ${NAMESPACE} -o yaml | grep ssh-privatekey | awk '{print $2}' > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
