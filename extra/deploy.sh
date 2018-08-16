#!/bin/bash

SHELL_DIR=$(dirname "$0")

NAME=${1}
VERSION=${2}
NAMESPACE=${3:-default}

${SHELL_DIR}/helm-init.sh

echo "$ helm upgrade --install $NAME-$NAMESPACE --version $VERSION --namespace $NAMESPACE"
helm upgrade --install $NAME-$NAMESPACE chartmuseum/$NAME \
            --version $VERSION --namespace $NAMESPACE --devel \
            --set fullnameOverride=$NAME-$NAMESPACE

echo "$ helm history $NAME"
helm history $NAME
