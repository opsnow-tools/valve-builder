#!/bin/bash

NAME=${1:-sample}
TYPE=${2:-ssh-privatekey}
NAMESPACE=${3:-devops}

mkdir -p /root/.ssh

echo "Host *" > /root/.ssh/config
echo "    StrictHostKeyChecking no" >> /root/.ssh/config

SECRET=$(kubectl get secret ${NAME} -n ${NAMESPACE} -o yaml | grep ${TYPE} | awk '{print $2}')

if [ ! -z ${SECRET} ]; then
    echo "${SECRET}" | base64 --decode > /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
fi

echo "" > /root/.ssh/known_hosts
