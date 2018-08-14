#!/bin/bash

SHELL_DIR=$(dirname "$0")

IMAGE_NAME=${1}
NAMESPACE=${2:-devops}

${SHELL_DIR}/helm-init.sh

if [ ! -z ${IMAGE_NAME} ] && [ -d charts/$IMAGE_NAME ]; then
    echo "$ charts/$IMAGE_NAME"
    cd charts/$IMAGE_NAME

    echo "$ helm lint ."
    helm lint .

    if [ ! -z ${CHARTMUSEUM} ]; then
        echo "$ helm push . chartmuseum"
        helm push . chartmuseum
    fi

    echo "$ helm repo update"
    helm repo update

    echo "$ helm search $IMAGE_NAME"
    helm search $IMAGE_NAME
fi
