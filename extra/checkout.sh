#!/bin/bash

SHELL_DIR=$(dirname "$0")

REPO=${1:-"sample"}
BRANCH=${2:-"master"}
SECRET=${3}
NAMESPACE=${4:-"devops"}

if [ ! -z ${SECRET} ]; then
    SECRET_TYPE="ssh-privatekey"
    SECRET_DIST="/root/.ssh/id_rsa"
    ${SHELL_DIR}/secret.sh ${SECRET} ${SECRET_TYPE} ${SECRET_DIST} ${NAMESPACE}
fi

echo "$ git clone ${REPO} -b ${BRANCH} ."
git clone ${REPO} -b ${BRANCH} .

${SHELL_DIR}/detect.sh
