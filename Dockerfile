# Dockerfile

FROM ubuntu:16.04

RUN apt-get update && apt-get install -y curl tar

RUN curl -sL toast.sh/helper/bastion.sh | bash

ENTRYPOINT ["bash"]
