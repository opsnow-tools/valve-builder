#!/bin/bash

DATE=$(date +%Y%m%d)

SHELL_DIR=$(dirname $0)

USERNAME=${1:-opsnow-tools}
REPONAME=${2:-valve-builder}

GIT_USERNAME="bot"
GIT_USEREMAIL="sbl@bespinglobal.com"

################################################################################

command -v tput > /dev/null || TPUT=false

_echo() {
    if [ -z ${TPUT} ] && [ ! -z $2 ]; then
        echo -e "$(tput setaf $2)$1$(tput sgr0)"
    else
        echo -e "$1"
    fi
}

_result() {
    echo
    _echo "# $@" 4
}

_command() {
    echo
    _echo "$ $@" 3
}

_success() {
    echo
    _echo "+ $@" 2
    exit 0
}

_error() {
    echo
    _echo "- $@" 1
    exit 1
}

_gen_version() {
    # previous versions
    VERSION=$(curl -s https://api.github.com/repos/${USERNAME}/${REPONAME}/releases/latest | grep tag_name | cut -d'"' -f4 | xargs)

    if [ ! -f ${SHELL_DIR}/VERSION ]; then
        echo "v0.0.0" > ${SHELL_DIR}/VERSION
    fi

    # release version
    if [ -z ${VERSION} ]; then
        VERSION=$(cat ${SHELL_DIR}/VERSION | xargs)
    else
        MAJOR=$(cat ${SHELL_DIR}/VERSION | xargs | cut -d'.' -f1)
        MINOR=$(cat ${SHELL_DIR}/VERSION | xargs | cut -d'.' -f2)

        LATEST_MAJOR=$(echo ${VERSION} | cut -d'.' -f1)
        LATEST_MINOR=$(echo ${VERSION} | cut -d'.' -f2)

        if [ "${MAJOR}" != "${LATEST_MAJOR}" ] || [ "${MINOR}" != "${LATEST_MINOR}" ]; then
            VERSION=$(cat ${SHELL_DIR}/VERSION | xargs)
        fi

        # add build version
        VERSION=$(echo ${VERSION} | perl -pe 's/^(([v\d]+\.)*)(\d+)(.*)$/$1.($3+1).$4/e')
    fi

    printf "${VERSION}" > ${SHELL_DIR}/target/VERSION
    _result "VERSION=${VERSION}"
}

_check_version() {
    REPO=${1}
    NAME=${2}
    G_NM=${3:-${NAME}}

    touch ${SHELL_DIR}/versions/${NAME}
    NOW=$(cat ${SHELL_DIR}/versions/${NAME} | xargs)

    # NWO=$(cat ${SHELL_DIR}/Dockerfile | grep "ENV ${NAME}" | awk '{print $3}')

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
        echo "${NEW}" > ${SHELL_DIR}/versions/${NAME}

        # replace version
        sed -i -e "s/ENV ${NAME} .*/ENV ${NAME} ${NEW}/g" ${SHELL_DIR}/Dockerfile

        # slack
        if [ ! -z ${SLACK_TOKEN} ]; then
            FOOTER="<https://github.com/${REPO}/${G_NM}|${REPO}/${G_NM}>"
            ${SHELL_DIR}/slack.sh --token="${SLACK_TOKEN}" --channel="tools" \
                --emoji=":construction_worker:" --username="valve" \
                --footer="${FOOTER}" --footer_icon="https://assets-cdn.github.com/favicon.ico" \
                --color="good" --title="${REPONAME} updated" "\`${NAME}\` ${NOW} > ${NEW}"
            _result " slack ${NAME} ${NOW} > ${NEW} "
            echo
        fi
    fi
}

if [ ! -z ${GITHUB_TOKEN} ]; then
    git config --global user.name "${GIT_USERNAME}"
    git config --global user.email "${GIT_USEREMAIL}"
fi

mkdir -p ${SHELL_DIR}/target
mkdir -p ${SHELL_DIR}/versions

_check_version "aws" "awscli" "aws-cli"
_check_version "kubernetes" "kubectl" "kubernetes"
_check_version "helm" "helm"
_check_version "Azure" "draft"

if [ ! -z ${GITHUB_TOKEN} ]; then
    echo

    # version
    _gen_version
    echo

    # commit log
    LIST=/tmp/versions
    ls ${SHELL_DIR}/versions > ${LIST}

    echo "${VERSION} at ${DATE}" > ${SHELL_DIR}/target/log

    while read VAL; do
        printf "%3s. %s\n" "${VAL}" "$(cat ${SHELL_DIR}/versions/${VAL} | xargs)" >> ${SHELL_DIR}/target/log
    done < ${LIST}

    _command "git add --all"
    git add --all

    # git commit
    _command "git commit -m $(cat ${SHELL_DIR}/target/log)"
    # git commit -m "updated at ${DATE}" > /dev/null 2>&1 || export CHANGED=true
    # git commit -m "$(cat ${SHELL_DIR}/target/log)" > /dev/null 2>&1 || export CHANGED=true
    git commit -m "$(cat ${SHELL_DIR}/target/log)"
    echo

    if [ ! -z ${CHANGED} ]; then
        # git push
        _command "git push github.com/${USERNAME}/${REPONAME} master"
        git push -q https://${GITHUB_TOKEN}@github.com/${USERNAME}/${REPONAME}.git master
        echo

        # git tag
        _command "git tag ${VERSION}"
        git tag ${VERSION}

        # git push
        _command "git push github.com/${USERNAME}/${REPONAME} ${VERSION}"
        git push -q https://${GITHUB_TOKEN}@github.com/${USERNAME}/${REPONAME}.git ${VERSION}
        echo
    fi
fi
