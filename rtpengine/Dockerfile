# BSD 2-Clause License

# Copyright (c) 2020, Supreeth Herle
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

FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV DEB_BUILD_PROFILES="pkg.ngcp-rtpengine.nobcg729"

# Install updates and dependencies
RUN apt-get update && \
	apt-get -y install git vim tmux dpkg-dev debhelper libxtables-dev default-libmysqlclient-dev gperf libavcodec-dev libavfilter-dev libavformat-dev \
					libavutil-dev libbencode-perl libcrypt-openssl-rsa-perl libcrypt-rijndael-perl libdigest-crc-perl libdigest-hmac-perl \
					libevent-dev libhiredis-dev libio-multiplex-perl libio-socket-inet6-perl libiptc-dev libjson-glib-dev libnet-interface-perl \
					libpcap0.8-dev libpcre3-dev libsocket6-perl libspandsp-dev libssl-dev libswresample-dev libsystemd-dev libxmlrpc-core-c3-dev \
					markdown dkms module-assistant keyutils libnfsidmap2 nfs-common rpcbind libglib2.0-dev zlib1g-dev libavcodec-extra \
					libcurl4-openssl-dev netcat-openbsd netcat iptables iproute2 net-tools iputils-ping libconfig-tiny-perl libwebsockets-dev

# Fetch RTPEngine code (tag mr7.4.1), build and install
RUN git clone https://github.com/sipwise/rtpengine && \
	cd rtpengine && git checkout mr9.4.1 && dpkg-checkbuilddeps && \
	dpkg-buildpackage -b -uc -us && cd .. && \
	dpkg -i *.deb && ldconfig

CMD /mnt/rtpengine/rtpengine_init.sh
