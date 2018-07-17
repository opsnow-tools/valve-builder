# Dockerfile

FROM alpine:latest

RUN apk --no-cache update && \
    apk --no-cache add git zip curl wget docker bash openssl ca-certificates && \
    rm -rf /var/cache/apk/*

WORKDIR /root
