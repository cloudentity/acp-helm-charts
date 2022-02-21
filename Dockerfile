FROM alpine/helm:latest

ARG PLUTO_VERSION=5.4.0

RUN wget https://github.com/FairwindsOps/pluto/releases/download/v${PLUTO_VERSION}/pluto_${PLUTO_VERSION}_linux_amd64.tar.gz && \
    tar xf pluto_${PLUTO_VERSION}_linux_amd64.tar.gz && \
    cp pluto /usr/bin

ENTRYPOINT ["/bin/sh", "-c"]
