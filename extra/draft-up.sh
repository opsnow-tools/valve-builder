#!/bin/bash

SHELL_DIR=$(dirname "$0")

IMAGE_NAME=${1}
NAMESPACE=${2:-default}

${SHELL_DIR}/draft-init.sh

if [ -f draft.toml ]; then
    echo "$ sed -i -e s/NAMESPACE/$NAMESPACE/g draft.toml"
    sed -i -e "s/NAMESPACE/$NAMESPACE/g" draft.toml

    echo "$ sed -i -e s/NAME/$IMAGE_NAME-$NAMESPACE/g draft.toml"
    sed -i -e "s/NAME/$IMAGE_NAME-$NAMESPACE/g" draft.toml

    echo "$ draft up"
    draft up
fi
