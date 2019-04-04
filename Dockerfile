# Dockerfile

FROM docker

RUN apk add -v --update python py-pip bash curl git jq openssh perl busybox-extras

ENV awscli 1.16.138
ENV awsauth 0.3.0
ENV kubectl v1.14.0
ENV helm v2.13.1
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

COPY .m2/ /root/.m2/

ENTRYPOINT ["bash"]
