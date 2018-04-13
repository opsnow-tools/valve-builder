# Dockerfile

FROM node:alpine

MAINTAINER me@nalbam.com

RUN apk --no-cache update && \
    apk --no-cache add gcc git zip curl docker python && \
    rm -rf /var/cache/apk/*
