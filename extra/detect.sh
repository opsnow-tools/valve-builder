#!/bin/bash

NAME=${1:-sample}
BRANCH=${2:-master}

get_version() {
    VERSION=
    REVISION=

    NODE=$(kubectl get ing -n default -o wide | grep sample-node | head -1 | awk '{print $2}')

    if [ ! -z ${NODE} ]; then
        VERSION=$(curl -sL -X POST http://${NODE}/counter/${NAME} | xargs)
    fi

    if [ -z ${VERSION} ]; then
        VERSION=0
        REVISION=$(TZ=Asia/Seoul date +%Y%m%d-%H%M%S)
    else
        REVISION=$(git rev-parse --short=6 HEAD)
    fi

    if [ "${BRANCH}" == "master" ]; then
        printf "0.1.${VERSION}-${REVISION}" > ${HOME}/VERSION
    else
        printf "0.0.${VERSION}-${BRANCH}" > ${HOME}/VERSION
    fi

    echo "# VERSION: $(cat ${HOME}/VERSION)"
}

get_language() {
    FILE=${1}
    LANG=${2}

    FIND=$(find . -name ${FILE} | head -1)

    if [ ! -z ${FIND} ]; then
        ROOT=$(dirname ${FIND})

        if [ ! -z ${ROOT} ]; then
            printf "$LANG" > ${HOME}/SOURCE_LANG
            printf "$ROOT" > ${HOME}/SOURCE_ROOT

            echo "# SOURCE_LANG: $(cat ${HOME}/SOURCE_LANG)"
            echo "# SOURCE_ROOT: $(cat ${HOME}/SOURCE_ROOT)"
        fi
    fi
}

get_version

printf "." > ${HOME}/SOURCE_ROOT
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || get_language pom.xml java
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || get_language package.json nodejs
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || printf "" > ${HOME}/SOURCE_LANG
