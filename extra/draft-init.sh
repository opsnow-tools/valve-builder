#!/bin/bash

echo "$ draft version --short"
draft version --short

echo "$ draft init"
draft init

REGISTRY=$(cat ${HOME}/REGISTRY)

if [ ! -z ${REGISTRY} ]; then
    echo "$ draft config set registry ${REGISTRY}"
    draft config set registry ${REGISTRY}
fi
