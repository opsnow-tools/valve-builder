#!/bin/bash

SHELL_DIR=$(dirname "$0")

NAME=$(cat ${HOME}/NAME)

NAMESPACE=${1:-devops}

${SHELL_DIR}/helm-init.sh

if [ ! -z ${NAME} ] && [ -d charts/$NAME ]; then
    echo "$ charts/$NAME"
    cd charts/$NAME

    echo "$ helm lint ."
    helm lint .

    if [ ! -z ${CHARTMUSEUM} ]; then
        echo "$ helm push . chartmuseum"
        helm push . chartmuseum
    fi

    echo "$ helm repo update"
    helm repo update

    echo "$ helm search $NAME"
    helm search $NAME
fi
