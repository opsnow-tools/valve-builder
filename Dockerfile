# Dockerfile

FROM alpine

RUN apk -v --update add python py-pip groff less mailcap bash curl git zip jq base64

ENV awscli 1.15.80
ENV kubectl v1.11.2
ENV helm v2.9.1
ENV draft v0.15.0

RUN pip install --upgrade awscli==${awscli} && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN curl -sL https://azuredraft.blob.core.windows.net/draft/draft-${draft}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/draft /usr/local/bin/draft

COPY extra/ /root/extra/

ENTRYPOINT ["bash"]
