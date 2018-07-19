# Dockerfile

FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y curl git tar jq docker python-pip && \
    pip install --upgrade --user awscli

RUN KUBECTL=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN HELM=$(curl -s https://api.github.com/repos/kubernetes/helm/releases/latest | jq --raw-output '.tag_name') && \
    curl -L https://storage.googleapis.com/kubernetes-helm/helm-${HELM}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN DRAFT=$(curl -s https://api.github.com/repos/Azure/draft/releases/latest | jq --raw-output '.tag_name') && \
    curl -L https://azuredraft.blob.core.windows.net/draft/draft-${DRAFT}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/draft /usr/local/bin/draft

RUN SKAFFOLD=$(curl -s https://api.github.com/repos/GoogleContainerTools/skaffold/releases/latest | jq --raw-output '.tag_name') && \
    curl -LO https://storage.googleapis.com/skaffold/releases/${SKAFFOLD}/skaffold-linux-amd64 && \
    chmod +x skaffold-linux-amd64 && mv skaffold-linux-amd64 /usr/local/bin/skaffold

WORKDIR /root

ENTRYPOINT ["bash"]
