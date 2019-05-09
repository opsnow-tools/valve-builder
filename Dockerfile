# Dockerfile

FROM docker

RUN apk add -v --update python3 python3-dev bash curl git jq openssh perl busybox-extras

ENV awscli 0
ENV awsauth 0
ENV kubectl 0
ENV helm 0
ENV argo 0

RUN pip3 install --upgrade awscli==${awscli} && \
    rm /var/cache/apk/*

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN curl -sLO https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${awsauth}/heptio-authenticator-aws_${awsauth}_linux_amd64 && \
    chmod +x heptio-authenticator-aws_${awsauth}_linux_amd64 && mv heptio-authenticator-aws_${awsauth}_linux_amd64 /usr/local/bin/aws-iam-authenticator

RUN curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN curl -sLO https://github.com/argoproj/argo/releases/download/${argo}/argo-linux-amd64 && \
    chmod +x argo-linux-amd64 && mv argo-linux-amd64 /usr/local/bin/argo

COPY .m2/ /root/.m2/

ENTRYPOINT ["bash"]
