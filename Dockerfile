# Dockerfile

FROM alpine:latest

MAINTAINER me@nalbam.com

RUN apk --no-cache update && \
    apk --no-cache add python py-pip curl git zip && \
    pip --no-cache-dir install awscli gcloud && \
    rm -rf /var/cache/apk/*
