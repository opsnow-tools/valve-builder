#!/bin/bash

SHELL_DIR=$(dirname $0)

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

if [ ! -f ${SHELL_DIR}/target/VERSION ]; then
    exit 0
fi

VERSION=$(cat ${SHELL_DIR}/target/VERSION | xargs)

_result "VERSION=${VERSION}"

go get github.com/tcnksm/ghr

ghr -t ${GITHUB_TOKEN} \
    -u ${CIRCLE_PROJECT_USERNAME} \
    -r ${CIRCLE_PROJECT_REPONAME} \
    -c ${CIRCLE_SHA1} \
    -delete ${VERSION} \
    ${SHELL_DIR}/versions/
