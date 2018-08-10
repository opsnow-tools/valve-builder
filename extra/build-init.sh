#!/bin/bash

NAME=${1:-sample}
BRANCH=${2:-master}
NAMESPACE=${3:-devops}
BASE_DOMAIN=

get_version() {
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
        printf "0.1.${VERSION}-${REVISION}" > ${HOME}/VERSION
    else
        printf "0.0.${VERSION}-${BRANCH}" > ${HOME}/VERSION
    fi

    echo "# VERSION: $(cat ${HOME}/VERSION)"
}

get_domain() {
    NAME=${1}
    SAVE=${2}

    DOMAIN=$(kubectl get ing -n ${NAMESPACE} -o wide | grep ${NAME} | head -1 | awk '{print $2}' | cut -d',' -f1)

    if [ ! -z ${DOMAIN} ]; then
        if [ "${NAME}" == "jenkins" ]; then
            BASE_DOMAIN=${DOMAIN:$(expr index $DOMAIN \.)}
            printf "$BASE_DOMAIN" > ${HOME}/BASE_DOMAIN
            echo "# BASE_DOMAIN: $(cat ${HOME}/BASE_DOMAIN)"
        fi

        if [ ! -z ${BASE_DOMAIN} ]; then
            DOMAIN="${NAME}-${NAMESPACE}.${BASE_DOMAIN}"
        fi
    fi

    printf "${DOMAIN}" > ${HOME}/${SAVE}
    echo "# ${SAVE}: $(cat ${HOME}/${SAVE})"
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

get_domain jenkins JENKINS
get_domain chartmuseum CHARTMUSEUM
get_domain docker-registry REGISTRY
get_domain sonarqube SONARQUBE
get_domain sonatype-nexus NEXUS

cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || get_language pom.xml java
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || get_language package.json nodejs
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || printf "" > ${HOME}/SOURCE_LANG && printf "." > ${HOME}/SOURCE_ROOT
