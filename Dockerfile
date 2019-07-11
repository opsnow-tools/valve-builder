# Dockerfile

FROM docker

RUN apk add -v --update python3 python3-dev bash curl git jq openssh perl busybox-extras

ENV awscli 1.16.159
ENV awsauth 0.3.0
ENV helm v2.14.2
ENV kubectl v1.14.4

RUN pip3 install --upgrade awscli==${awscli} && \
    rm /var/cache/apk/*

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN curl -sLO https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${awsauth}/heptio-authenticator-aws_${awsauth}_linux_amd64 && \
    chmod +x heptio-authenticator-aws_${awsauth}_linux_amd64 && mv heptio-authenticator-aws_${awsauth}_linux_amd64 /usr/local/bin/aws-iam-authenticator

COPY .m2/ /root/.m2/

ENTRYPOINT ["bash"]
