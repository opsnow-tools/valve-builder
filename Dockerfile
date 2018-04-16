# Dockerfile

FROM alpine:latest

MAINTAINER me@nalbam.com

RUN apk --no-cache update && \
    apk --no-cache add git zip curl docker python && \
    rm -rf /var/cache/apk/*

WORKDIR /root
