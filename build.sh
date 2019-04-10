#!/bin/bash

OS_NAME="$(uname | awk '{print tolower($0)}')"

SHELL_DIR=$(dirname $0)

CMD=${1:-${CIRCLE_JOB}}

USERNAME=${CIRCLE_PROJECT_USERNAME:-opsnow-tools}
REPONAME=${CIRCLE_PROJECT_REPONAME:-valve-builder}

BRANCH=${CIRCLE_BRANCH:-master}

BUCKET="repo.opsnow.io"

GIT_USERNAME="bot"
GIT_USEREMAIL="sre@bespinglobal.com"

################################################################################

# command -v tput > /dev/null && TPUT=true
TPUT=

_echo() {
    if [ "${TPUT}" != "" ] && [ "$2" != "" ]; then
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

_replace() {
    if [ "${OS_NAME}" == "darwin" ]; then
        sed -i "" -e "$1" $2
    else
        sed -i -e "$1" $2
    fi
}

_prepare() {
    # target
    mkdir -p ${SHELL_DIR}/target/dist
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

    _result "BRANCH=${BRANCH}"
    _result "PR_NUM=${PR_NUM}"
    _result "PR_URL=${PR_URL}"

    # version
    if [ "${BRANCH}" == "master" ]; then
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
    NAME=${1}
    REPO=${2}
    TRIM=${3}

    touch ${SHELL_DIR}/versions/${NAME}

    NOW=$(cat ${SHELL_DIR}/versions/${NAME} | xargs)

    if [ "${NAME}" == "awscli" ]; then
        pushd ${SHELL_DIR}/target
        curl -sLO https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
        unzip awscli-bundle.zip
        popd

        NEW=$(ls ${SHELL_DIR}/target/awscli-bundle/packages/ | grep awscli | sed 's/awscli-//' | sed 's/.tar.gz//' | xargs)

        rm -rf ${SHELL_DIR}/target/awscli-*
    else
        NEW=$(curl -s https://api.github.com/repos/${REPO}/releases/latest | grep tag_name | cut -d'"' -f4 | xargs)
    fi

    if [ "${NEW}" == "" ]; then
        return
    fi

    if [ "${TRIM}" == "" ]; then
        CURR="${NEW}"
    else
        CURR=$(echo "${NEW}" | cut -d'v' -f2)
    fi

    _result "$(printf '%-25s %-25s %-25s' "${NAME}" "${NOW}" "${NEW}")"

    if [ "${NEW}" != "${NOW}" ]; then
        CHANGED=true

        printf "${NEW}" > ${SHELL_DIR}/versions/${NAME}
        printf "${NEW}" > ${SHELL_DIR}/target/dist/${NAME}

        # replace
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${CURR}/g" ${SHELL_DIR}/Dockerfile
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${CURR}/g" ${SHELL_DIR}/README.md

        # slack
        _slack "${NAME}" "${REPO}" "${NEW}"
    fi
}

_slack() {
    NAME=${1}
    REPO=${2}
    CURR=${3}

    if [ -z ${SLACK_TOKEN} ]; then
        return
    fi

    curl -sL repo.opsnow.io/valve-ctl/slack | bash -s -- \
        --token="${SLACK_TOKEN}" --username="${USERNAME}" \
        --footer="<https://github.com/${REPO}/releases/tag/${CURR}|${REPO}>" \
        --footer_icon="https://repo.opspresso.com/favicon/github.png" \
        --color="good" --title="${NAME} updated" "\`${CURR}\`"
}

_git_push() {
    if [ -z ${GITHUB_TOKEN} ]; then
        return
    fi

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
    _gen_version

    _result "VERSION=${VERSION}"

    _check_version "kubectl" "kubernetes/kubernetes"
    _check_version "helm" "helm/helm"
    _check_version "draft" "Azure/draft"

    if [ ! -z ${CHANGED} ]; then
        _check_version "awscli" "aws/aws-cli"
        _check_version "awsauth" "kubernetes-sigs/aws-iam-authenticator" "v"

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
    if [ -z ${GITHUB_TOKEN} ]; then
        return
    fi
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

    _command "ghr ${VERSION} ${SHELL_DIR}/target/dist/"
    ghr -t ${GITHUB_TOKEN:-EMPTY} \
        -u ${USERNAME} \
        -r ${REPONAME} \
        -c ${CIRCLE_SHA1} \
        ${GHR_PARAM} \
        ${VERSION} ${SHELL_DIR}/target/dist/
}

_prepare

case ${CMD} in
    package)
        _package
        ;;
    publish)
        _publish
        ;;
    release)
        _release
        ;;
esac
