# Dockerfile

FROM docker

RUN apk add -v --update python py-pip bash curl git jq openssh perl

ENV awscli 1.16.30
ENV kubectl v1.12.1
ENV helm v2.11.0
ENV draft v0.16.0

RUN pip install --upgrade awscli==${awscli} && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN curl -sL https://azuredraft.blob.core.windows.net/draft/draft-${draft}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/draft /usr/local/bin/draft

RUN curl -sLO https://raw.githubusercontent.com/opsnow-tools/valve-butler/master/src/com/opsnow/valve/Butler.groovy && \
    mv Butler.groovy /root/Butler.groovy

COPY slack.sh /usr/local/bin/slack

COPY .m2/ /root/.m2/

ENTRYPOINT ["bash"]
