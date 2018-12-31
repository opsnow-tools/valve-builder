#!/bin/bash

SHELL_DIR=$(dirname $0)

CMD=${1:-${CIRCLE_JOB}}

USERNAME=${CIRCLE_PROJECT_USERNAME:-opsnow-tools}
REPONAME=${CIRCLE_PROJECT_REPONAME:-valve-builder}

BUCKET="repo.opsnow.io"

GIT_USERNAME="bot"
GIT_USEREMAIL="sbl@bespinglobal.com"

################################################################################

# command -v tput > /dev/null || TPUT=false
TPUT=false

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

_prepare() {
    # target
    mkdir -p ${SHELL_DIR}/target
    mkdir -p ${SHELL_DIR}/versions

    # 755
    find ./** | grep [.]sh | xargs chmod 755
}

_get_version() {
    # latest versions
    VERSION=$(curl -s https://api.github.com/repos/${USERNAME}/${REPONAME}/releases/latest | grep tag_name | cut -d'"' -f4 | xargs)

    if [ -z ${VERSION} ]; then
        VERSION=$(curl -sL ${BUCKET}/${REPONAME}/VERSION | xargs)
    fi

    if [ ! -f ${SHELL_DIR}/VERSION ]; then
        printf "v0.0.0" > ${SHELL_DIR}/VERSION
    fi

    if [ -z ${VERSION} ]; then
        VERSION=$(cat ${SHELL_DIR}/VERSION | xargs)
    fi
}

_gen_version() {
    _get_version

    # release version
    MAJOR=$(cat ${SHELL_DIR}/VERSION | xargs | cut -d'.' -f1)
    MINOR=$(cat ${SHELL_DIR}/VERSION | xargs | cut -d'.' -f2)

    LATEST_MAJOR=$(echo ${VERSION} | cut -d'.' -f1)
    LATEST_MINOR=$(echo ${VERSION} | cut -d'.' -f2)

    if [ "${MAJOR}" != "${LATEST_MAJOR}" ] || [ "${MINOR}" != "${LATEST_MINOR}" ]; then
        VERSION=$(cat ${SHELL_DIR}/VERSION | xargs)
    fi

    _result "CIRCLE_BRANCH=${CIRCLE_BRANCH}"
    _result "PR_NUM=${PR_NUM}"
    _result "PR_URL=${PR_URL}"

    # version
    if [ "${CIRCLE_BRANCH}" == "master" ]; then
        VERSION=$(echo ${VERSION} | perl -pe 's/^(([v\d]+\.)*)(\d+)(.*)$/$1.($3+1).$4/e')
        printf "${VERSION}" > ${SHELL_DIR}/target/VERSION
    else
        if [ "${PR_NUM}" == "" ]; then
            if [ "${PR_URL}" != "" ]; then
                PR_NUM=$(echo $PR_URL | cut -d'/' -f7)
            else
                PR_NUM=${CIRCLE_BUILD_NUM}
            fi
        fi

        printf "${PR_NUM}" > ${SHELL_DIR}/target/PRE

        VERSION="${VERSION}-${PR_NUM}"
        printf "${VERSION}" > ${SHELL_DIR}/target/VERSION
    fi
}

_check_version() {
    REPO=${1}
    NAME=${2}
    G_NM=${3:-${NAME}}

    touch ${SHELL_DIR}/versions/${NAME}
    NOW=$(cat ${SHELL_DIR}/versions/${NAME} | xargs)

    # NWO=$(cat ${SHELL_DIR}/Dockerfile | grep "ENV ${NAME}" | awk '{print $3}')

    if [ "${NAME}" == "awscli" ]; then
        pushd ${SHELL_DIR}/target
        curl -sLO https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
        unzip awscli-bundle.zip
        popd

        NEW=$(ls ${SHELL_DIR}/target/awscli-bundle/packages/ | grep awscli | sed 's/awscli-//' | sed 's/.tar.gz//' | xargs)

        rm -rf ${SHELL_DIR}/target/awscli-*
    elif [ "${NAME}" == "kubectl" ]; then
        NEW=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt | xargs)
    else
        NEW=$(curl -s https://api.github.com/repos/${REPO}/${NAME}/releases/latest | grep tag_name | cut -d'"' -f4 | xargs)
    fi

    _result "$(printf '%-10s %-10s %-10s' "${NAME}" "${NOW}" "${NEW}")"

    if [ "${NEW}" != "" ] && [ "${NEW}" != "${NOW}" ]; then
        CHANGED=true

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
        fi
    fi
}

_git_push() {
    _gen_version

    _result "VERSION=${VERSION}"

    # commit log
    LIST=/tmp/versions
    ls ${SHELL_DIR}/versions | sort > ${LIST}

    echo "${REPONAME} ${VERSION}" > ${SHELL_DIR}/target/log

    while read VAL; do
        echo "${VAL} $(cat ${SHELL_DIR}/versions/${VAL} | xargs)" >> ${SHELL_DIR}/target/log
    done < ${LIST}

    git config --global user.name "${GIT_USERNAME}"
    git config --global user.email "${GIT_USEREMAIL}"

    _command "git add --all"
    git add --all

    _command "git commit -m $(cat ${SHELL_DIR}/target/log)"
    git commit -m "$(cat ${SHELL_DIR}/target/log)"

    _command "git push github.com/${USERNAME}/${REPONAME} master"
    git push -q https://${GITHUB_TOKEN}@github.com/${USERNAME}/${REPONAME}.git master
}

_s3_sync() {
    _command "aws s3 sync ${1} s3://${2}/ --acl public-read"
    aws s3 sync ${1} s3://${2}/ --acl public-read
}

_cf_reset() {
    CFID=$(aws cloudfront list-distributions --query "DistributionList.Items[].{Id:Id, DomainName: DomainName, OriginDomainName: Origins.Items[0].DomainName}[?contains(OriginDomainName, '${1}')] | [0]" | jq -r '.Id')
    if [ "${CFID}" != "" ]; then
        aws cloudfront create-invalidation --distribution-id ${CFID} --paths "/*"
    fi
}

_package() {
    _check_version "kubernetes" "kubectl" "kubernetes"
    _check_version "helm" "helm"
    _check_version "Azure" "draft"

    if [ ! -z ${GITHUB_TOKEN} ] && [ ! -z ${CHANGED} ]; then
        _check_version "aws" "awscli" "aws-cli"

        _git_push
    else
        rm -rf ${SHELL_DIR}/target
    fi
}

_publish() {
    if [ ! -f ${SHELL_DIR}/target/VERSION ]; then
        return
    fi
    if [ -f ${SHELL_DIR}/target/PRE ]; then
        return
    fi

    _s3_sync "${SHELL_DIR}/target/" "${BUCKET}/${REPONAME}"

    _cf_reset "${BUCKET}"
}

_release() {
    if [ ! -f ${SHELL_DIR}/target/VERSION ]; then
        return
    fi
    if [ -f ${SHELL_DIR}/target/PRE ]; then
        GHR_PARAM="-delete -prerelease"
    else
        GHR_PARAM="-delete"
    fi

    VERSION=$(cat ${SHELL_DIR}/target/VERSION | xargs)

    _result "VERSION=${VERSION}"

    _command "go get github.com/tcnksm/ghr"
    go get github.com/tcnksm/ghr

    _command "ghr ${VERSION} ${SHELL_DIR}/versions/"
    ghr -t ${GITHUB_TOKEN:-EMPTY} \
        -u ${USERNAME} \
        -r ${REPONAME} \
        -c ${CIRCLE_SHA1} \
        ${GHR_PARAM} \
        ${VERSION} ${SHELL_DIR}/versions/
}

_prepare

case ${CMD} in
    package)
        _package
        ;;
    release)
        _release
        ;;
esac
