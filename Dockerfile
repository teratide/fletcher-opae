FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y cmake gcc g++ make git uuid-dev libjson-c-dev

ADD . /src
WORKDIR /build
