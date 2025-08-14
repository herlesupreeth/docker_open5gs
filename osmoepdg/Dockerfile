# BSD 2-Clause License

# Copyright (c) 2020-2025, Supreeth Herle
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV OSMOCOM_REPO="https://downloads.osmocom.org/packages/osmocom:/latest/Debian_12"

# Install updates and dependencies
RUN apt-get update && \
    apt-get -y install wget gnupg

RUN wget $OSMOCOM_REPO/Release.key && \
    mv Release.key /etc/apt/trusted.gpg.d/osmocom-latest.asc && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/osmocom-latest.asc] $OSMOCOM_REPO/ ./" > /etc/apt/sources.list.d/osmocom-latest.list

# Install more dependencies
RUN apt-get update && \
    apt-get -y install telnet iproute2 net-tools git pkg-config autoconf make libtool gettext gperf libgmp-dev bison flex automake autotools-dev rebar3 libosmocore-utils libosmocore-dev libgtpnl-dev libgtpnl-tools libpcap-dev nftables tcpdump

# Compile osmocom-epdg
RUN git clone https://gitea.osmocom.org/erlang/osmo-epdg && \
    cd osmo-epdg && \
    git checkout tags/0.1.1 && \
    rebar3 compile && \
    rebar3 escriptize

# Compile strongswan-epdg
RUN git clone https://github.com/herlesupreeth/strongswan-epdg && \
    cd strongswan-epdg && \
    git checkout fix_dns_parse && \
    autoreconf -i && \
    ./configure \
        --sysconfdir=/etc \
        --enable-eap-aka \
        --enable-eap-aka-3gpp \
        --enable-eap-aka-3gpp2 \
        --enable-eap-simaka-reauth \
        --enable-save-keys \
        --enable-p-cscf \
        --enable-osmo-epdg \
        --enable-swanctl --enable-vici --enable-charon --disable-systemd

RUN cd strongswan-epdg && \
    make -j`nproc` && make install

CMD ["/mnt/osmoepdg/osmoepdg_init.sh"]
