#!/bin/bash

IMAGE_NAME=${1}

REGISTRY = readFile "/home/jenkins/REGISTRY"
VERSION = readFile "/home/jenkins/VERSION"

if [ -f Dockerfile ]; then
    echo "$ docker build -t $REGISTRY/$IMAGE_NAME:$VERSION ."
    docker build -t $REGISTRY/$IMAGE_NAME:$VERSION .

    echo "$ docker push $REGISTRY/$IMAGE_NAME:$VERSION"
    docker push $REGISTRY/$IMAGE_NAME:$VERSION
fi
