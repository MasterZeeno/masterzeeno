FROM debian:bookworm AS builder

RUN apt update && apt install -y \
  build-essential git wget curl \
  musl-tools \
  gcc-aarch64-linux-gnu \
  gcc-arm-linux-gnueabihf \
  file

WORKDIR /src

RUN curl -LO https://ftp.de.debian.org/debian/pool/main/f/figlet/figlet_2.2.5.orig.tar.gz && \
    tar xf figlet_2.2.5.orig.tar.gz && \
    mv figlet-2.2.5 figlet && \
    rm figlet_2.2.5.orig.tar.gz

WORKDIR /src/figlet

RUN sed -i \
  -e 's/^CC =.*/CC ?= gcc/' \
  -e 's/^LD =.*/LD ?= $(CC)/' \
  -e 's/^CFLAGS =.*/CFLAGS ?= -O2 -Wall/' \
  -e 's/^LDFLAGS =.*/LDFLAGS ?=/' \
  Makefile

RUN make clean && \
    make CC=musl-gcc LDFLAGS="-static" && \
    cp figlet /output/figlet-x86_64 && \
    make clean && \
    make CC=aarch64-linux-gnu-gcc CFLAGS="-static -O2" LDFLAGS="-static" && \
    cp figlet /output/figlet-aarch64 && \
    make clean && \
    make CC=arm-linux-gnueabihf-gcc CFLAGS="-static -O2" LDFLAGS="-static" && \
    cp figlet /output/figlet-armv7

FROM scratch AS output
COPY --from=builder /output /builds