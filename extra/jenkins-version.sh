#!/bin/bash

NAME=${1:-sample}
VERSION=

NODE=$(kubectl get ing -n default -o wide | grep sample-node | head -1 | awk '{print $2}')

if [ ! -z ${NODE} ]; then
    VERSION=$(curl -sL -X POST http://${NODE}/counter/${NAME} | xargs)
fi

if [ -z ${VERSION} ]; then
    LIST=/home/jenkins/.version/list
    TEMP=/tmp/.version

    echo "# version" > ${TEMP}

    if [ -f ${LIST} ]; then
        while read LINE; do
            ARR=(${LINE})

            if [ "${ARR[0]}" == "#" ]; then
                continue
            fi

            if [ "${ARR[0]}" == "${NAME}" ]; then
                VER=$(( ${ARR[1]} + 1 ))
                VERSION=${VER}
            else
                VER=${ARR[1]}
            fi

            echo "${ARR[0]} ${VER}" >> ${TEMP}
        done < ${LIST}
    fi

    if [ -z ${VERSION} ]; then
        VERSION=1
        echo "${NAME} ${VERSION}" >> ${TEMP}
    fi

    cp -rf ${TEMP} ${LIST}
fi

printf "0.1.${VERSION}" > /home/jenkins/VERSION

echo "# version: $(cat /home/jenkins/VERSION)"
