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

            echo "# SOURCE_LANG: $(cat ${HOME}/SOURCE_LANG)"
            echo "# SOURCE_ROOT: $(cat ${HOME}/SOURCE_ROOT)"
        fi
    fi
}

printf "." > ${HOME}/SOURCE_ROOT
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || get_language pom.xml java
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || get_language package.json nodejs
cat ${HOME}/SOURCE_LANG > /dev/null 2>&1 || printf "" > ${HOME}/SOURCE_LANG
