# Dockerfile

FROM ubuntu:16.04

ENV TZ Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get install git curl tar bash openssl ca-certificates python-pip && \
    pip install awscli

RUN JQ=$(curl -s https://api.github.com/repos/stedolan/jq/releases/latest | jq --raw-output '.tag_name') && \
    curl -sLO https://github.com/stedolan/jq/releases/download/${JQ}/jq-linux64 && \
    chmod +x jq-linux64 && mv jq-linux64 /usr/local/bin/jq

RUN KUBECTL=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) && \
    curl -sLO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN HELM=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq --raw-output '.tag_name') && \
    curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${HELM}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN DRAFT=$(curl -s https://api.github.com/repos/Azure/draft/releases/latest | jq --raw-output '.tag_name') && \
    curl -sL https://azuredraft.blob.core.windows.net/draft/draft-${DRAFT}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/draft /usr/local/bin/draft

#RUN SKAFFOLD=$(curl -s https://api.github.com/repos/GoogleContainerTools/skaffold/releases/latest | jq --raw-output '.tag_name') && \
#    curl -sLO https://storage.googleapis.com/skaffold/releases/${SKAFFOLD}/skaffold-linux-amd64 && \
#    chmod +x skaffold-linux-amd64 && mv skaffold-linux-amd64 /usr/local/bin/skaffold

RUN ISTIOCTL=$(curl -s https://api.github.com/repos/istio/istio/releases/latest | jq --raw-output '.tag_name') && \
    curl -sL https://github.com/istio/istio/releases/download/${ISTIOCTL}/istio-${ISTIOCTL}-linux.tar.gz | tar xz && \
    mv istio-${ISTIOCTL}/bin/istioctl /usr/local/bin/istioctl

COPY extra/ /root/extra/

ENTRYPOINT ["bash"]
