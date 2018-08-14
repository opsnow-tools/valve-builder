#!/bin/bash

SHELL_DIR=$(dirname "$0")

IMAGE_NAME=${1}
VERSION=${2}
NAMESPACE=${3:-default}

${SHELL_DIR}/helm-init.sh

echo "$ helm upgrade --install $IMAGE_NAME-$NAMESPACE --version $VERSION --namespace $NAMESPACE"
helm upgrade --install $IMAGE_NAME-$NAMESPACE chartmuseum/$IMAGE_NAME \
            --version $VERSION --namespace $NAMESPACE --devel \
            --set fullnameOverride=$IMAGE_NAME-$NAMESPACE

echo "$ helm history $IMAGE_NAME-$NAMESPACE"
helm history $IMAGE_NAME-$NAMESPACE
