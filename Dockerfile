# Dockerfile

FROM centos:7

MAINTAINER me@nalbam.com

RUN yum update -y && yum install -y git zip curl wget docker python-pip
