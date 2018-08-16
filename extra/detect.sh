#!/bin/bash

NAME=$(cat ${HOME}/NAME)
BASE_DOMAIN=$(cat ${HOME}/BASE_DOMAIN)
REGISTRY=$(cat ${HOME}/REGISTRY)

VERSION="0.0.0"

get_version() {
    PATCH=
    REVISION=

    SAMPLE=$(kubectl get ing -n default -o wide | grep sample-node | head -1 | awk '{print $2}')

    if [ ! -z ${SAMPLE} ]; then
        PATCH=$(curl -sL -X POST http://${SAMPLE}/counter/${NAME} | xargs)
    fi

    if [ -z ${PATCH} ]; then
        PATCH="1"
        REVISION=$(TZ=Asia/Seoul date +%Y%m%d-%H%M%S)
    elif [ -d .git ]; then
        REVISION=$(git rev-parse --short=6 HEAD)
    else
        REVISION="sample"
    fi

    if [ "${BRANCH}" == "master" ]; then
        VERSION="0.1.${PATCH}-${REVISION}"
    else
        VERSION="0.0.${PATCH}-${BRANCH}"
    fi

    printf "${VERSION}" > ${HOME}/VERSION
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
        fi
    fi
}

get_version

printf "." > ${HOME}/SOURCE_ROOT
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || get_language pom.xml java
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || get_language package.json nodejs
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || printf "" > ${HOME}/SOURCE_LANG

echo "# SOURCE_LANG: $(cat ${HOME}/SOURCE_LANG)"
echo "# SOURCE_ROOT: $(cat ${HOME}/SOURCE_ROOT)"

if [ -f charts/acme/Chart.yaml ]; then
    echo "$ sed -i -e s/name: .*/name: $NAME/ charts/acme/Chart.yaml"
    sed -i -e "s/name: .*/name: $NAME/" charts/acme/Chart.yaml

    echo "$ sed -i -e s/version: .*/version: $VERSION/ charts/acme/Chart.yaml"
    sed -i -e "s/version: .*/version: $VERSION/" charts/acme/Chart.yaml
fi

if [ -f charts/acme/values.yaml ]; then
    echo "$ sed -i -e s|basedomain: .*|basedomain: $BASE_DOMAIN| charts/acme/values.yaml"
    sed -i -e "s|basedomain: .*|basedomain: $BASE_DOMAIN|" charts/acme/values.yaml

    echo "$ sed -i -e s|repository: .*|repository: $REGISTRY/$NAME| charts/acme/values.yaml"
    sed -i -e "s|repository: .*|repository: $REGISTRY/$NAME|" charts/acme/values.yaml

    echo "$ sed -i -e s|tag: .*|tag: $VERSION| charts/acme/values.yaml"
    sed -i -e "s|tag: .*|tag: $VERSION|" charts/acme/values.yaml
fi

if [ -d charts/acme ]; then
    echo "$ mv charts/acme charts/$NAME"
    mv charts/acme charts/$NAME
fi
