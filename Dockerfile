# syntax=docker/dockerfile:1
FROM ubuntu:20.04
LABEL Description="CORE Docker Image"

# define variables
ARG DEBIAN_FRONTEND=noninteractive
ARG PREFIX=/usr/local
ARG BRANCH=master
ARG CORE_TARBALL=core.tar.gz
ARG OSPF_TARBALL=ospf.tar.gz

# install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    automake \
    bash \
    ca-certificates \
    ethtool \
    gawk \
    gcc \
    g++ \
    iproute2 \
    iputils-ping \
    libc-dev \
    libev-dev \
    libreadline-dev \
    libtool \
    libtk-img \
    make \
    nftables \
    python3 \
    python3-pip \
    python3-tk \
    pkg-config \
    systemctl \
    tk \
    wget \
    xauth \
    xterm \
    && apt-get clean

# install python dependencies
RUN python3 -m pip install \
    grpcio==1.27.2 \
    grpcio-tools==1.27.2 \
    poetry==1.1.7
# retrieve, build, and install core

RUN wget -q -O ${CORE_TARBALL} https://github.com/coreemu/core/archive/refs/tags/release-8.2.0.tar.gz && \
    tar xf ${CORE_TARBALL} && \
    cd coreemu-core* && \
    ./bootstrap.sh && \
    ./configure && \
    make -j $(nproc) && \
    make install && \
    cd daemon && \
    python3 -m poetry build -f wheel && \
    python3 -m pip install dist/* && \
    cp scripts/* ${PREFIX}/bin && \
    mkdir /etc/core && \
    cp -n data/core.conf /etc/core && \
    cp -n data/logging.conf /etc/core && \
    mkdir -p ${PREFIX}/share/core && \
    cp -r examples ${PREFIX}/share/core && \
    echo '\
[Unit]\n\
Description=Common Open Research Emulator Service\n\
After=network.target\n\
\n\
[Service]\n\
Type=simple\n\
ExecStart=/usr/local/bin/core-daemon\n\
TasksMax=infinity\n\
\n\
[Install]\n\
WantedBy=multi-user.target\
' > /lib/systemd/system/core-daemon.service && \
    cd ../.. && \
    rm ${CORE_TARBALL} && \
    rm -rf coreemu-core*
# retrieve, build, and install ospf mdr
RUN wget -q -O ${OSPF_TARBALL} https://github.com/USNavalResearchLaboratory/ospf-mdr/tarball/master && \
    tar xf ${OSPF_TARBALL} && \
    cd USNavalResearchLaboratory-ospf-mdr* && \
    ./bootstrap.sh && \
    ./configure --disable-doc --enable-user=root --enable-group=root \
        --with-cflags=-ggdb --sysconfdir=/usr/local/etc/quagga --enable-vtysh \
        --localstatedir=/var/run/quagga && \
    make -j $(nproc) && \
    make install && \
    cd .. && \
    rm ${OSPF_TARBALL} && \
    rm -rf USNavalResearchLaboratory-ospf-mdr*
# retrieve and install emane packages
RUN wget -q https://adjacentlink.com/downloads/emane/emane-1.2.7-release-1.ubuntu-20_04.amd64.tar.gz && \
    tar xf emane*.tar.gz && \
    cd emane-1.2.7-release-1/debs/ubuntu-20_04/amd64 && \
    apt-get install -y ./emane*.deb ./python3-emane_*.deb && \
    cd ../../../.. && \
    rm emane-1.2.7-release-1.ubuntu-20_04.amd64.tar.gz && \
    rm -rf emane-1.2.7-release-1

RUN apt-get install -y --no-install-recommends \
    wireshark \
    dsniff \
    netcat \
    traceroute \
    tcpdump \
    packeth \
    nmap \
    vim \
    arp-scan \
    arping \
    x11-xserver-utils \
    locales \
    isc-dhcp-server \
    isc-dhcp-client \
    && apt-get clean
RUN echo '\
xterm*VT100.Translations: #override \\n\n\
                 Ctrl Shift <Key>V:    insert-selection(CLIPBOARD)\n\
                 Ctrl Shift <Key>C:    copy-selection(CLIPBOARD)\n\
XTerm.vt100.faceName: DejaVuSansMono\n\
XTerm.vt100.faceSize: 12\n\
XTerm.vt100.locale: true\n\
XTerm.vt100.backarrowKey: false\n\
XTerm.ttyModes: erase ^?\n\
XTerm.vt100.scrollBar: true\n\
XTerm.vt100.metaSendsEscape: true\n\
' > ~/.Xresources && \
    echo 'en_US.UTF-8 UTF-8\n\
ru_RU.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen && \
    echo /etc/default/locale > 'LANG=ru_RU.UTF-8'

RUN systemctl enable isc-dhcp-server

CMD ["systemctl", "start", "core-daemon"]
