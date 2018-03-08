# Dockerfile

FROM centos:7

MAINTAINER me@nalbam.com

RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y git zip curl wget docker python-pip && \
    pip install awscli

VOLUME /root/.aws
VOLUME /work

WORKDIR /work
