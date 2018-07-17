# Dockerfile

FROM python:3.5.5

RUN apk --no-cache update && \
    apk --no-cache add git zip curl docker bash openssl ca-certificates && \
    rm -rf /var/cache/apk/* && \
    pip install awscli

WORKDIR /root
