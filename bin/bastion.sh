#!/bin/bash

OS_NAME="linux"

# version
DATE=
KUBECTL=
KOPS=
HELM=
DRAFT=

# for ubuntu
export LC_ALL=C

# update
echo "================================================================================"
title "# update..."

sudo apt update
sudo apt upgrade -y
sudo apt install -y python-pip

# aws-cli
echo "================================================================================"
title "# install aws-cli..."

pip install --upgrade --user awscli

aws --version

# kubectl
echo "================================================================================"
title "# install kubectl..."

VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -LO https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/${OS_NAME}/amd64/kubectl
chmod +x kubectl && sudo mv kubectl /usr/local/bin/kubectl

kubectl version --client --short

# kops
echo "================================================================================"
title "# install kops..."

VERSION=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | jq --raw-output '.tag_name')
curl -LO https://github.com/kubernetes/kops/releases/download/${VERSION}/kops-${OS_NAME}-amd64
chmod +x kops-${OS_NAME}-amd64 && sudo mv kops-${OS_NAME}-amd64 /usr/local/bin/kops

kops version

# helm
echo "================================================================================"
title "# install helm..."

VERSION=$(curl -s https://api.github.com/repos/kubernetes/helm/releases/latest | jq --raw-output '.tag_name')
curl -L https://storage.googleapis.com/kubernetes-helm/helm-${VERSION}-${OS_NAME}-amd64.tar.gz | tar xz
sudo mv ${OS_NAME}-amd64/helm /usr/local/bin/helm && rm -rf ${OS_NAME}-amd64

helm version --client --short

# draft
echo "================================================================================"
title "# install draft..."

VERSION=$(curl -s https://api.github.com/repos/Azure/draft/releases/latest | jq --raw-output '.tag_name')
curl -L https://azuredraft.blob.core.windows.net/draft/draft-${VERSION}-${OS_NAME}-amd64.tar.gz | tar xz
sudo mv ${OS_NAME}-amd64/draft /usr/local/bin/draft && rm -rf ${OS_NAME}-amd64

draft version --short

echo "================================================================================"
title "# clean all..."

sudo apt clean all
sudo apt autoremove -y

echo "================================================================================"

title "# Done."
