# Dockerfile

FROM centos:7

MAINTAINER me@nalbam.com

ENV USER jenkins
ENV HOME /home/${USER}

RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y git zip curl wget docker python-pip java-1.8.0-openjdk-devel maven nodejs && \
    pip install awscli ansible && \
    systemctl enable docker && \
    systemctl start docker && \
    groupadd docker && \
    useradd -c "Jenkins User" -d ${HOME} -m ${USER} && \
    usermod -aG docker ${USER}

USER ${USER}

VOLUME ${HOME}

CMD /bin/bash
