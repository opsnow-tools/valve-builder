#!/bin/bash

USERNAME=${1}
REPONAME=${2}
GITHUB_TOKEN=${3}
MESSAGE=

echo "USERNAME: ${USERNAME}"
echo "REPONAME: ${REPONAME}"

get_version() {
    REPO=$1
    NAME=$2
    STRIP=$3

    mkdir -p versions
    touch versions/${NAME}

    NOW=$(cat versions/${NAME})

    if [ "${NAME}" == "kubectl" ]; then
        NEW=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt | xargs)
    else
        NEW=$(curl -s https://api.github.com/repos/${REPO}/${NAME}/releases/latest | grep tag_name | cut -d'"' -f4 | xargs)
    fi
    if [ ! -z ${STRIP} ]; then
        NEW=$(echo "${NEW}" | cut -c 2-)
    fi

    echo "${REPO}/${NAME}: ${NOW} ${NEW}"

    if [ "${NOW}" != "${NEW}" ]; then
        printf "${NEW}" > versions/${NAME}
        sed -i -e "s/ENV ${NAME} .*/ENV VERSION ${NEW}/g" Dockerfile
        MESSAGE="${NAME} ${NEW}"
    fi
}

get_version kubernetes kubectl
# get_version kubernetes kops
get_version helm helm
get_version Azure draft
# get_version GoogleContainerTools skaffold
# get_version hashicorp terraform true
# get_version istio istio

if [ "x${MESSAGE}" != "x" ]; then
    git config --global user.name "bot"
    git config --global user.email "ops@nalbam.com"

    git add --all
    git commit -m "${MESSAGE}"
    git push -q https://${GITHUB_TOKEN}@github.com/${USERNAME}/${REPONAME}.git master
fi
