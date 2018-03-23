# Dockerfile

FROM centos:7

MAINTAINER me@nalbam.com

RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y git zip curl wget docker python python-pip

RUN pip install awscli docker

ENV USER jenkins
ENV HOME /home/${USER}

RUN useradd -c "Jenkins User" -d ${HOME} -m ${USER} && \
    usermod -aG docker ${USER}

USER ${USER}

VOLUME ${HOME}

CMD /bin/bash
