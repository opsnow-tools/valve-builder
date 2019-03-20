# Dockerfile

FROM docker

RUN apk add -v --update python py-pip bash curl git jq openssh perl busybox-extras

ENV awscli 1.16.122
ENV awsauth 0.3.0
ENV kubectl v1.11.8
ENV helm v2.13.0
ENV draft v0.16.0

RUN pip install --upgrade awscli==${awscli} && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN curl -sLO https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${awsauth}/heptio-authenticator-aws_${awsauth}_linux_amd64 && \
    chmod +x heptio-authenticator-aws_${awsauth}_linux_amd64 && mv heptio-authenticator-aws_${awsauth}_linux_amd64 /usr/local/bin/aws-iam-authenticator

RUN curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN curl -sL https://azuredraft.blob.core.windows.net/draft/draft-${draft}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/draft /usr/local/bin/draft

RUN curl -sLO https://raw.githubusercontent.com/opsnow-tools/valve-butler/master/src/com/opsnow/valve/Butler.groovy && \
    mv Butler.groovy /root/Butler.groovy

COPY .m2/ /root/.m2/

ENTRYPOINT ["bash"]
