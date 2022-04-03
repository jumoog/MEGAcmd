FROM ubuntu:20.04 as build

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get update &&\
    apt-get install -y autoconf libtool g++ libcrypto++-dev libz-dev libsqlite3-dev libssl-dev \
                   libcurl4-gnutls-dev libreadline-dev libpcre++-dev libsodium-dev libc-ares-dev \
                   libfreeimage-dev libavcodec-dev libavutil-dev libavformat-dev libswscale-dev \
                   libmediainfo-dev libzen-dev libuv1-dev git make &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN \
    git clone https://github.com/meganz/MEGAcmd.git &&\
    cd MEGAcmd &&\
    git submodule update --init --recursive &&\
    sh autogen.sh &&\
    ./configure --disable-dependency-tracking &&\
    make -j12 &&\
    make install
    
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /usr/local/lib/libmega.so* /usr/local/lib/
RUN \
    apt-get update &&\
    apt-get install -y --no-install-recommends libc-ares2 \
    libc6 libgcc-s1 libmediainfo0v5 libpcrecpp0v5 libstdc++6 \
    libzen0v5 zlib1g libavcodec58 libavformat58 libswscale5 \
    libcrypto++6 libuv1 libsodium23 libfreeimage3 &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    ldconfig
