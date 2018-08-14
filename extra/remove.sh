#!/bin/bash

SHELL_DIR=$(dirname "$0")

IMAGE_NAME=${1}
NAMESPACE=${2:-default}

${SHELL_DIR}/helm-init.sh

echo "$ helm search $IMAGE_NAME"
helm search $IMAGE_NAME

echo "$ helm history $IMAGE_NAME-$NAMESPACE"
helm history $IMAGE_NAME-$NAMESPACE

echo "$ helm delete --purge $IMAGE_NAME-$NAMESPACE"
helm delete --purge $IMAGE_NAME-$NAMESPACE
