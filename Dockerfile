# Dockerfile

FROM python:slim

ENV TZ Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y git curl zip jq && \
    pip install awscli

RUN KUBECTL=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) && \
    curl -sLO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN HELM=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name') && \
    curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${HELM}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN DRAFT=$(curl -s https://api.github.com/repos/Azure/draft/releases/latest | jq -r '.tag_name') && \
    curl -sL https://azuredraft.blob.core.windows.net/draft/draft-${DRAFT}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/draft /usr/local/bin/draft

RUN ISTIOCTL=$(curl -s https://api.github.com/repos/istio/istio/releases/latest | jq -r '.tag_name') && \
    curl -sL https://github.com/istio/istio/releases/download/${ISTIOCTL}/istio-${ISTIOCTL}-linux.tar.gz | tar xz && \
    mv istio-${ISTIOCTL}/bin/istioctl /usr/local/bin/istioctl

RUN TERRAFORM=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r '.tag_name' | cut -c 2-) && \
    curl -sLO https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM}_linux_amd64.zip && rm -rf terraform_${TERRAFORM}_linux_amd64.zip && \
    mv terraform /usr/local/bin/terraform

COPY extra/ /root/extra/

ENTRYPOINT ["bash"]
