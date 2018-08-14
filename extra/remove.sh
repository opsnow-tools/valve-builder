#!/bin/bash

SHELL_DIR=$(dirname "$0")

NAME=${1}
NAMESPACE=${2:-default}

${SHELL_DIR}/helm-init.sh

echo "$ helm search $NAME"
helm search $NAME

echo "$ helm history $NAME-$NAMESPACE"
helm history $NAME-$NAMESPACE

echo "$ helm delete --purge $NAME-$NAMESPACE"
helm delete --purge $NAME-$NAMESPACE
