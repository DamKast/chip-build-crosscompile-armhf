ARG VERSION=0.6.25
FROM connectedhomeip/chip-build:${VERSION}

RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -fy --no-install-recommends \
    git \
    g++-arm-linux-gnueabihf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && : # last line


# Need to have the sysroot archive in the repo folder.

# Old:
# COPY ./raspberry-armhf-sysroot.tar.xz /opt

COPY ./raspberry-buster-armhf-sysroot.tar.xz /opt

WORKDIR /opt
# Unpack the sysroot, while also removing some rather large items in it that
# are generally not required for compilation
RUN set -x \
    && tar xfvJ raspberry-buster-armhf-sysroot.tar.xz \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/usr/lib/firmware \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/usr/lib/git-core \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/usr/lib/modules \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/lib/firmware \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/lib/git-core \
    && rm -rf /opt/raspberry-buster-armhf-sysroot/lib/modules \
    && : # last line

RUN ln -s /opt/raspberry-buster-armhf-sysroot/usr/lib/ /opt/raspberry-buster-armhf-sysroot/lib

ENV SYSROOT_ARMHF=/opt/raspberry-buster-armhf-sysroot
ENV PKG_CONFIG_PATH=/opt/raspberry-buster-armhf-sysroot/usr/lib/arm-linux-gnueabihf/pkgconfig
