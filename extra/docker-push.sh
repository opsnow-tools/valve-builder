#!/bin/bash

NAME=${1}
VERSION=latest

if [ -f /home/jenkins/VERSION ]; then
    VERSION=$(cat /home/jenkins/VERSION)
fi

REGISTRY=docker-registry

if [ -f /home/jenkins/REGISTRY ]; then
    REGISTRY=$(cat /home/jenkins/REGISTRY)
fi

if [ -z $NAME ]; then
    echo "Name is empty!"
    exit 1
fi

echo "# NAME: ${NAME}"
echo "# VERSION: ${VERSION}"

echo "$ docker build -t $REGISTRY/$NAME:$VERSION ."
docker build -t $REGISTRY/$NAME:$VERSION .

echo "$ docker push $REGISTRY/$NAME:$VERSION"
docker push $REGISTRY/$NAME:$VERSION
