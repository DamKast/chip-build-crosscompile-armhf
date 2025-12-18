ARG VERSION=0.7.25
FROM connectedhomeip/chip-build:${VERSION}

# Install build dependencies and compile Python 3.11 from source
RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -fy --no-install-recommends \
    git \
    g++-arm-linux-gnueabihf \
    zstd \
    wget \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libdb5.3-dev \
    libbz2-dev \
    libexpat1-dev \
    liblzma-dev \
    libffi-dev \
    && cd /tmp \
    && wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz \
    && tar -xzf Python-3.11.9.tgz \
    && cd Python-3.11.9 \
    && ./configure --enable-optimizations --prefix=/usr/local \
    && make -j$(nproc) \
    && make altinstall \
    && cd / \
    && rm -rf /tmp/Python-3.11.9* \
    && update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python python /usr/local/bin/python3.11 1 \
    && python3.11 -m pip install --upgrade pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/


# Need to have the sysroot archive in the repo folder.

# Old:
# COPY ./raspberry-armhf-sysroot.tar.xz /opt

COPY ./raspberry-buster-armhf-sysroot.tar.xz /opt

WORKDIR /opt
# Unpack the sysroot, while also removing some rather large items in it that
# are generally not required for compilation
RUN set -x \
    && mkdir -p /opt/raspberry-buster-armhf-sysroot \
    && tar xfvJ raspberry-buster-armhf-sysroot.tar.xz -C /opt/raspberry-buster-armhf-sysroot \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/usr/lib/firmware \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/usr/lib/git-core \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/usr/lib/modules \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/lib/firmware \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/lib/git-core \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/lib/modules

RUN rm -rf /opt/raspberry-buster-armhf-sysroot/lib 2>/dev/null || true \
    && ln -s /opt/raspberry-buster-armhf-sysroot/usr/lib /opt/raspberry-buster-armhf-sysroot/lib

ENV SYSROOT_ARMHF=/opt/raspberry-buster-armhf-sysroot
ENV PKG_CONFIG_PATH=/opt/raspberry-buster-armhf-sysroot/usr/lib/arm-linux-gnueabihf/pkgconfig
