# Dockerfile

FROM alpine:latest

MAINTAINER me@nalbam.com

RUN apk --no-cache update && \
    apk --no-cache add gcc git zip curl docker python python-dev py-pip && \
    rm -rf /var/cache/apk/*
