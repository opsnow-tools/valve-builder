#!/bin/bash

NAME=${1:-"sample"}
TYPE=${2:-"ssh-privatekey"}
DIST=${3:-"/root/.ssh/id_rsa"}
NAMESPACE=${4:-"devops"}

if [ "${TYPE}" == "ssh-privatekey" ]; then
    mkdir -p /root/.ssh

    echo "Host *" > /root/.ssh/config
    echo "    StrictHostKeyChecking no" >> /root/.ssh/config

    echo "" > /root/.ssh/known_hosts
fi

SECRET=$(kubectl get secret ${NAME} -n ${NAMESPACE} -o json | jq '.data' | grep ${TYPE} | cut -d'"' -f4)

if [ ! -z ${SECRET} ]; then
    # echo "${SECRET}" | base64 -d > ${DIST}
    echo "${SECRET}" > /tmp/encoded
    base64 -d /tmp/encoded > ${DIST}
    chmod 600 ${DIST}
fi
