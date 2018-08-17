#!/bin/bash

SHELL_DIR=$(dirname "$0")

repo=
branch=
secret=
namespace=

for v in "$@"; do
    case ${v} in
    -b=*|--branch=*)
        branch="${v#*=}"
        shift
        ;;
    -s=*|--secret=*)
        secret="${v#*=}"
        shift
        ;;
    -n=*|--namespace=*)
        namespace="${v#*=}"
        shift
        ;;
    *)
        repo=$*
        break
        ;;
    esac
done

if [ -z ${branch} ]; then
    branch="master"
fi
if [ -z ${namespace} ]; then
    namespace="devops"
fi

if [ ! -z ${secret} ]; then
    mkdir -p /root/.ssh

    echo "Host *" > /root/.ssh/config
    echo "    StrictHostKeyChecking no" >> /root/.ssh/config

    echo "" > /root/.ssh/known_hosts

    SECRET=$(kubectl get secret ${secret} -n ${namespace} -o json | jq '.data' | grep ssh-privatekey | cut -d'"' -f4)

    if [ ! -z ${SECRET} ]; then
        echo "${SECRET}" | base64 -d > /root/.ssh/id_rsa
        chmod 600 /root/.ssh/id_rsa
    fi
fi

echo "git clone ${repo} -b ${branch} ."
git clone ${repo} -b ${branch} .

${SHELL_DIR}/detect.sh
