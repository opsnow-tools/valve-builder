#!/bin/bash

if [ ! -f workspace/target/VERSION ]; then
    exit 0
fi

VERSION=$(cat workspace/target/VERSION | xargs)

go get github.com/tcnksm/ghr

ghr -t ${GITHUB_TOKEN} \
    -u ${CIRCLE_PROJECT_USERNAME} \
    -r ${CIRCLE_PROJECT_REPONAME} \
    -c ${CIRCLE_SHA1} \
    -delete ${VERSION} \
    workspace/versions/
