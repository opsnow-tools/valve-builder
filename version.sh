#!/bin/bash

SHELL_DIR=$(dirname $0)

USERNAME=${1:-opsnow-tools}
REPONAME=${2:-valve-builder}
GITHUB_TOKEN=${3}
SLACK_TOKEN=${4}

CHANGED=

check() {
    REPO=$1
    NAME=$2

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
        echo

        NEW=$(ls target/awscli-bundle/packages/ | grep awscli | sed 's/awscli-//' | sed 's/.tar.gz//' | xargs)
    elif [ "${NAME}" == "kubectl" ]; then
        NEW=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt | xargs)
    else
        NEW=$(curl -s https://api.github.com/repos/${REPO}/${NAME}/releases/latest | grep tag_name | cut -d'"' -f4 | xargs)
    fi

    printf '# %-10s %-10s %-10s\n' "${NAME}" "${NOW}" "${NEW}"

    if [ "${NOW}" != "${NEW}" ]; then
        CHANGED=true

        printf "${NEW}" > ${SHELL_DIR}/versions/${NAME}
        sed -i -e "s/ENV ${NAME} .*/ENV ${NAME} ${NEW}/g" ${SHELL_DIR}/Dockerfile

        if [ ! -z ${GITHUB_TOKEN} ]; then
            git add --all
            git commit -m "${NAME} ${NEW}"
            echo
        fi

        if [ ! -z ${SLACK_TOKEN} ]; then
            ${SHELL_DIR}/slack.sh --token="${SLACK_TOKEN}" \
                --color="good" --title="builder version updated" --emoji=":construction_worker:" "\`${NAME}\` ${NOW} > ${NEW}"
            echo " slack ${NAME} ${NOW} > ${NEW} "
            echo
        fi
    fi
}

if [ ! -z ${GITHUB_TOKEN} ]; then
    git config --global user.name "bot"
    git config --global user.email "bot@nalbam.com"
fi

check aws awscli
check kubernetes kubectl
check helm helm
check Azure draft

if [ ! -z ${GITHUB_TOKEN} ]; then
    echo

    echo "# git push github.com/${USERNAME}/${REPONAME} master"
    git push -q https://${GITHUB_TOKEN}@github.com/${USERNAME}/${REPONAME}.git master
    echo

    # if [ ! -z ${CHANGED} ]; then
    #     DATE=$(date +%Y%m%d)
    #     git tag ${DATE}

    #     echo "# git push github.com/${USERNAME}/${REPONAME} ${DATE}"
    #     git push -q https://${GITHUB_TOKEN}@github.com/${USERNAME}/${REPONAME}.git ${DATE}
    #     echo
    # fi
fi
