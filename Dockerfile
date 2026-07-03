FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILDROOT_VERSION=2026.02.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bc \
    bison \
    build-essential \
    ca-certificates \
    cpio \
    curl \
    file \
    flex \
    git \
    libncurses-dev \
    libssl-dev \
    locales \
    make \
    patch \
    perl \
    python3 \
    qemu-system-arm \
    qemu-system-data \
    qemu-utils \
    rsync \
    tar \
    unzip \
    wget \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

RUN curl -L "https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.xz" \
    | tar -C /opt -xJ \
  && chmod -R a+rX "/opt/buildroot-${BUILDROOT_VERSION}"

COPY docker/buildroot-dl/ /opt/buildroot-dl/
COPY scripts/lab-entrypoint.sh /usr/local/bin/lab-entrypoint.sh

RUN chmod -R a+rX /opt/buildroot-dl \
  && chmod 0755 /usr/local/bin/lab-entrypoint.sh

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV HOME=/tmp
ENV BUILDROOT_VERSION=${BUILDROOT_VERSION}
ENV BUILDROOT_DIR=/opt/buildroot-${BUILDROOT_VERSION}
ENV BUILDROOT_DL_DIR=/work/.cache/dl

WORKDIR /work

ENTRYPOINT ["/usr/local/bin/lab-entrypoint.sh"]
CMD ["bash"]
