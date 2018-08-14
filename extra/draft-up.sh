#!/bin/bash

SHELL_DIR=$(dirname "$0")

NAME=$(cat ${HOME}/NAME)

NAMESPACE=${1:-default}

${SHELL_DIR}/draft-init.sh

if [ ! -f draft.toml ]; then
    echo "Not found draft.toml"
    exit 1
fi

echo "$ sed -i -e s/NAMESPACE/$NAMESPACE/g draft.toml"
sed -i -e "s/NAMESPACE/$NAMESPACE/g" draft.toml

echo "$ sed -i -e s/NAME/$NAME-$NAMESPACE/g draft.toml"
sed -i -e "s/NAME/$NAME-$NAMESPACE/g" draft.toml

echo "$ draft up -e $NAMESPACE"
draft up -e $NAMESPACE
