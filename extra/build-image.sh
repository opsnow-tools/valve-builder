#!/bin/sh

NAME=$(cat ${HOME}/NAME)
REGISTRY=$(cat ${HOME}/REGISTRY)
VERSION=$(cat ${HOME}/VERSION)

if [ -f Dockerfile ]; then
    echo "$ docker build -t $REGISTRY/$NAME:$VERSION ."
    docker build -t $REGISTRY/$NAME:$VERSION .

    echo "$ docker push $REGISTRY/$NAME:$VERSION"
    docker push $REGISTRY/$NAME:$VERSION
fi
