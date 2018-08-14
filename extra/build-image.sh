#!/bin/sh

NAME=$(cat ${HOME}/NAME)
REGISTRY=$(cat ${HOME}/REGISTRY)
VERSION=$(cat ${HOME}/VERSION)

if [ ! -f Dockerfile ]; then
    echo "Not found Dockerfile"
    exit 1
fi

echo "$ docker build -t $REGISTRY/$NAME:$VERSION ."
docker build -t $REGISTRY/$NAME:$VERSION .

echo "$ docker push $REGISTRY/$NAME:$VERSION"
docker push $REGISTRY/$NAME:$VERSION
