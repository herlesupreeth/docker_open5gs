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

# Install updates and dependencies
RUN apt-get update && \
	apt-get -y install mysql-server tcpdump screen tmux ntp ntpdate git-core dkms \
					gcc flex bison libmysqlclient-dev make libssl-dev libcurl4-openssl-dev \
					libxml2-dev libpcre2-dev bash-completion g++ autoconf libmnl-dev \
					libsctp-dev libradcli-dev libradcli4 libjson-c-dev pkg-config iproute2 net-tools \
					iputils-ping libgcrypt20-dev

# Fetch Kamailio code
RUN mkdir -p /usr/local/src/ && cd /usr/local/src/ && \
	git clone https://github.com/kamailio/kamailio && \
	cd kamailio && git checkout 4fb8accc6747ad56fec3dc84d70cb2b8bbd7316e

# Build and Install Kamailio
RUN cd /usr/local/src/kamailio && make cfg
COPY modules.lst /usr/local/src/kamailio/src
RUN cd /usr/local/src/kamailio && \
	make -j`nproc` Q=0 all | tee make_all.txt && \
	make install | tee make_install.txt && \
	ldconfig

COPY kamailio_init.sh /
CMD /kamailio_init.sh
