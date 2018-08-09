#!/bin/bash

NAME=${1:-sample}
BRANCH=${2:-master}

VERSION=
REVISION=

NODE=$(kubectl get ing -n default -o wide | grep sample-node | head -1 | awk '{print $2}')

if [ ! -z ${NODE} ]; then
    VERSION=$(curl -sL -X POST http://${NODE}/counter/${NAME} | xargs)
fi

if [ -z ${VERSION} ]; then
    VERSION=0
    REVISION=$(date +%Y%m%d-%H%M%S)
else
    REVISION=$(git rev-parse --short=6 HEAD)
fi

if [ "${BRANCH}" == "master" ]; then
    printf "0.1.${VERSION}-${REVISION}" > /home/jenkins/VERSION
else
    printf "0.0.${VERSION}-${BRANCH}" > /home/jenkins/VERSION
fi

echo "# VERSION: $(cat /home/jenkins/VERSION)"
