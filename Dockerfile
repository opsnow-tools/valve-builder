# Dockerfile

FROM alpine:latest

MAINTAINER me@nalbam.com

RUN apk --no-cache update && \
    apk --no-cache add python py-pip py-setuptools ca-certificates curl git zip docker && \
    pip --no-cache-dir install awscli gcloud && \
    rm -rf /var/cache/apk/*
