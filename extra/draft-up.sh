#!/bin/bash

IMAGE_NAME=${1}
NAMESPACE=${2:-default}

echo "$ draft version --short"
draft version --short

echo "$ draft init"
draft init

REGISTRY=$(kubectl get ing -n ${1:-devops} -o wide | grep docker-registry | awk '{print $2}')

if [ ! -z ${REGISTRY} ]; then
    echo "$ draft config set registry ${REGISTRY}"
    draft config set registry ${REGISTRY}
fi

if [ -f draft.toml ]; then
    echo "$ sed -i -e s/NAMESPACE/$NAMESPACE/g draft.toml"
    sed -i -e "s/NAMESPACE/$NAMESPACE/g" draft.toml

    echo "$ sed -i -e s/NAME/$IMAGE_NAME-$NAMESPACE/g draft.toml"
    sed -i -e "s/NAME/$IMAGE_NAME-$NAMESPACE/g" draft.toml

    echo "$ draft up"
    draft up
fi
