# Dockerfile

FROM centos:7

MAINTAINER me@nalbam.com

RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y git zip curl wget docker lookup python-pip java-1.8.0-openjdk-devel maven nodejs && \
    pip install awscli ansible

CMD /bin/bash
