# Development container for OpenBMC builds.
# Package list and locale setup mirror ubuntu-24/build-setup.sh so the dev
# environment matches the build container. The Ubuntu version is selected by
# the UBUNTU_VERSION build arg (see ubuntu-XX/devcontainer.json).
ARG DOCKER_REG=public.ecr.aws/ubuntu
ARG UBUNTU_VERSION=24.04
FROM ${DOCKER_REG}/ubuntu:${UBUNTU_VERSION}

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yy \
    build-essential \
    chrpath \
    cpio \
    cmake \
    debianutils \
    diffstat \
    file \
    gawk \
    git \
    git-lfs \
    iputils-ping \
    libaudit-dev \
    libdata-dumper-simple-perl \
    lz4 \
    libsdl1.2-dev \
    libthread-queue-any-perl \
    libldap2-dev \
    libboost-all-dev \
    libpam-dev \
    libsystemd-dev \
    locales \
    meson \
    ninja-build \
    pkg-config \
    python3 \
    python3-dev \
    python3-setuptools \
    python3-inflection \
    python3-yaml \
    python3-mako \
    socat \
    subversion \
    texinfo \
    vim \
    wget \
    zstd \
    && rm -rf /var/lib/apt/lists/*

RUN if dpkg --compare-versions "$UBUNTU_VERSION" ge "24.04"; then \
    apt-get update && apt-get install -yy \
    libsystemd-dev; \
    else \
        apt-get update && apt-get install -yy \
        libtinyxml2-dev \
        libssl-dev; \
fi

RUN git lfs install --system

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Ubuntu 24.04+ ships a default "ubuntu" user with UID 1000. Remove it so the
# development user can take UID 1000 (as the build script does).
RUN if id ubuntu > /dev/null 2>&1; then userdel -r ubuntu > /dev/null 2>&1; fi
RUN getent group ${USER_GID} > /dev/null || groupadd -g ${USER_GID} ${USERNAME}
RUN getent passwd ${USER_UID} > /dev/null || useradd -m -u ${USER_UID} -g ${USER_GID} ${USERNAME}

USER ${USERNAME}
