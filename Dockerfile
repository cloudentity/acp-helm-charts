FROM alpine/helm:latest

ARG PLUTO_VERSION=5.4.0
ARG KUBEVAL_VERSION=v0.16.1

RUN wget -q https://github.com/FairwindsOps/pluto/releases/download/v${PLUTO_VERSION}/pluto_${PLUTO_VERSION}_linux_amd64.tar.gz && \
    tar xf pluto_${PLUTO_VERSION}_linux_amd64.tar.gz && \
    cp pluto /usr/bin

RUN wget -q https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz \
  && tar -xf kubeval-linux-amd64.tar.gz && \
  mv kubeval /usr/local/bin/kubeval

ENTRYPOINT ["/bin/sh", "-c"]
