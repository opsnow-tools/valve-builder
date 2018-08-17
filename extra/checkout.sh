#!/bin/bash

SHELL_DIR=$(dirname "$0")

REPO=${1:-"sample"}
BRANCH=${2:-"master"}
SECRET=${3}
NAMESPACE=${4:-"devops"}

if [ ! -z ${SECRET} ]; then
    mkdir -p /root/.ssh

    echo "Host *" > /root/.ssh/config
    echo "    StrictHostKeyChecking no" >> /root/.ssh/config

    echo "" > /root/.ssh/known_hosts

    ENCODED=$(kubectl get secret ${SECRET} -n ${NAMESPACE} -o json | jq '.data' | grep ssh-privatekey | cut -d'"' -f4)

    if [ ! -z ${ENCODED} ]; then
        echo "${ENCODED}" | base64 -d > /root/.ssh/id_rsa
        chmod 600 /root/.ssh/id_rsa
    fi
fi

echo "$ git clone ${REPO} -b ${BRANCH} ."
git clone ${REPO} -b ${BRANCH} .

${SHELL_DIR}/detect.sh
