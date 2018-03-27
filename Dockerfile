# Dockerfile

FROM centos:latest

MAINTAINER me@nalbam.com

RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y git zip curl wget docker python-pip java-1.8.0-openjdk-devel maven nodejs && \
    pip install awscli gcloud ansible

RUN yum install -y lookup ifconfig telnet

CMD /bin/bash
