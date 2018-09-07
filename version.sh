#!/bin/bash

SHELL_DIR=$(dirname $0)

USERNAME=${1:-nalbam}
REPONAME=${2:-builder}
GITHUB_TOKEN=${3}

CHANGED=

check() {
    REPO=$1
    NAME=$2
    STRIP=$3

    mkdir -p ${SHELL_DIR}/versions
    touch ${SHELL_DIR}/versions/${NAME}

    NOW=$(cat ${SHELL_DIR}/versions/${NAME} | xargs)

    if [ "${NAME}" == "awscli" ]; then
        rm -rf target
        mkdir -p target

        pushd target
        curl -sLO https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
        unzip awscli-bundle.zip
        popd

        NEW=$(ls target/awscli-bundle/packages/ | grep awscli | sed 's/awscli-//' | sed 's/.tar.gz//' | xargs)
    elif [ "${NAME}" == "kubectl" ]; then
        NEW=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt | xargs)
    else
        NEW=$(curl -s https://api.github.com/repos/${REPO}/${NAME}/releases/latest | grep tag_name | cut -d'"' -f4 | xargs)
    fi
    if [ ! -z ${STRIP} ]; then
        NEW=$(echo "${NEW}" | cut -c 2-)
    fi

    printf '# %-10s %-10s %-10s\n' "${NAME}" "${NOW}" "${NEW}"

    if [ "${NOW}" != "${NEW}" ]; then
        printf "${NEW}" > ${SHELL_DIR}/versions/${NAME}
        sed -i -e "s/ENV ${NAME} .*/ENV ${NAME} ${NEW}/g" Dockerfile

        printf '# %-10s %-10s\n' "${NAME}" "${NEW}"

        if [ ! -z ${GITHUB_TOKEN} ]; then
            git add --all
            git commit -m "${NAME} ${NEW}" > /dev/null 2>&1 || export CHANGED=true
        fi
    fi
}

if [ ! -z ${GITHUB_TOKEN} ]; then
    git config --global user.name "bot"
    git config --global user.email "ops@nalbam.com"
fi

check aws awscli
check kubernetes kubectl
check helm helm
check Azure draft

if [ ! -z ${CHANGED} ] && [ ! -z ${GITHUB_TOKEN} ]; then
    echo "# git push github.com/${USERNAME}/${REPONAME} master"
    git push -q https://${GITHUB_TOKEN}@github.com/${USERNAME}/${REPONAME}.git master

    DATE=$(date +%Y%m%d)
    git tag ${DATE}

    echo "# git push github.com/${USERNAME}/${REPONAME} ${DATE}"
    git push -q https://${GITHUB_TOKEN}@github.com/${USERNAME}/${REPONAME}.git ${DATE}
fi
