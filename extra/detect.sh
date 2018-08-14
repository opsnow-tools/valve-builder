#!/bin/bash

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

printf "." > ${HOME}/SOURCE_ROOT
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || get_language pom.xml java
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || get_language package.json nodejs
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || printf "" > ${HOME}/SOURCE_LANG

echo "# SOURCE_LANG: $(cat ${HOME}/SOURCE_LANG)"
echo "# SOURCE_ROOT: $(cat ${HOME}/SOURCE_ROOT)"

if [ -f charts/acme/Chart.yaml ]; then
    echo "$ sed -i -e s/name: .*/name: $IMAGE_NAME/ charts/acme/Chart.yaml"
    sed -i -e "s/name: .*/name: $IMAGE_NAME/" charts/acme/Chart.yaml

    echo "$ sed -i -e s/version: .*/version: $VERSION/ charts/acme/Chart.yaml"
    sed -i -e "s/version: .*/version: $VERSION/" charts/acme/Chart.yaml

    echo "$ sed -i -e s|basedomain: .*|basedomain: $BASE_DOMAIN| charts/acme/values.yaml"
    sed -i -e "s|basedomain: .*|basedomain: $BASE_DOMAIN|" charts/acme/values.yaml

    echo "$ sed -i -e s|repository: .*|repository: $REGISTRY/$IMAGE_NAME| charts/acme/values.yaml"
    sed -i -e "s|repository: .*|repository: $REGISTRY/$IMAGE_NAME|" charts/acme/values.yaml

    echo "$ sed -i -e s|tag: .*|tag: $VERSION| charts/acme/values.yaml"
    sed -i -e "s|tag: .*|tag: $VERSION|" charts/acme/values.yaml

    echo "$ mv charts/acme charts/$IMAGE_NAME"
    mv charts/acme charts/$IMAGE_NAME
fi
