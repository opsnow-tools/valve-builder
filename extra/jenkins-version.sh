#!/bin/bash

NAME=${1:-sample}
VERSION=1

LIST=/home/jenkins/.version/list
TEMP=/tmp/.version

echo "# version" > ${TEMP}

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

if [ "${VERSION}" == "1" ]; then
    echo "${NAME} ${VERSION}" >> ${TEMP}
fi

echo "${VERSION}" > /home/jenkins/VERSION

cp -rf ${TEMP} ${LIST}
