ARG VERSION=latest
FROM connectedhomeip/chip-build:${VERSION} as build

RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -fy --no-install-recommends \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && : # last line

WORKDIR /opt

COPY ./raspberry-armhf-sysroot.tar.xz /opt
# Unpack the sysroot, while also removing some rather large items in it that
# are generally not required for compilation
RUN set -x \
    && tar xfvJ raspberry-armhf-sysroot.tar.xz \
    && rm -rf /opt/raspberry-armhf-sysroot/usr/lib/firmware \
    && rm -rf /opt/raspberry-armhf-sysroot/usr/lib/git-core \
    && rm -rf /opt/raspberry-armhf-sysroot/usr/lib/modules \
    && rm -rf /opt/raspberry-armhf-sysroot/lib/firmware \
    && rm -rf /opt/raspberry-armhf-sysroot/lib/git-core \
    && rm -rf /opt/raspberry-armhf-sysroot/lib/modules \
    && : # last line

FROM connectedhomeip/chip-build:${VERSION}

COPY --from=build /opt/raspberry-armhf-sysroot/ /opt/raspberry-armhf-sysroot/

# Required symlinks for 32-bit
# RUN set -x \
#     && ln -s /usr/lib/armv7-linux-gnueabihf /usr/lib/arm-linux-gnueabihf
#     && ln -s /usr/lib/armv7-linux-gnueabihf /usr/include/lib/arm-linux-gnueabihf

ENV SYSROOT_ARMHF=/opt/raspberry-armhf-sysroot
