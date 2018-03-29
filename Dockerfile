# Dockerfile

FROM centos:latest

MAINTAINER me@nalbam.com

RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y git zip curl wget docker python-pip nodejs java-1.8.0-openjdk-devel maven && \
    pip install awscli gcloud ansible

RUN yum install -y lookup nslookup ifconfig telnet

CMD /bin/bash
