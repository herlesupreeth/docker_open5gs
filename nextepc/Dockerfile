# BSD 2-Clause License

# Copyright (c) 2019, Supreeth Herle
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

FROM ubuntu:bionic

# Install updates and dependencies
RUN apt-get -y update && apt-get upgrade -y && \
    apt-get -y install autoconf libtool gcc pkg-config git flex bison libsctp-dev \
                    libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev \
                    libbson-dev libyaml-dev vim ifupdown mongodb curl gnupg gdb iptables
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs && \
    apt-get autoremove -y && apt-get clean

# Get NextEPC code and install
RUN git clone --recursive https://github.com/open5gs/nextepc && cd nextepc && \
    git checkout tags/v0.4.4 && autoreconf -iv && \
    ./configure --prefix=`pwd`/install && make -j `nproc` && make install

# Set appropriate configuration file changes

# Set the working directory to nextepc
WORKDIR nextepc

# Building WebUI of NextEPC
RUN cd webui && npm install

# Copy the sample configuration file and script to modify conf file
COPY nextepc.conf mod_conf.sh install/etc/nextepc/

# Set the basic parameters of the EPC. In order to change these parameters at runtime,
# alter these parameters in file 'docker_env'
ENV MCC=001 \
    MNC=01 \
    TAC1=1 \
    EPC_IF=enp0s3

# Create tun interface and assign IP address range of UEs
# Run mongodb server
# Run WebUI
# Set iptables for routing internet traffic out of docker
# Sleep for 20 sec (Wait for mongodb to be ready) and Run NextEPC all-in-one configuration
CMD cd install/etc/nextepc && ./mod_conf.sh && \
    mongod --smallfiles --dbpath /var/lib/mongodb --logpath /var/log/mongodb/mongodb.log & \
    cd webui && npm run dev & \
    if ! iptables-save | grep -- "-A INPUT -i pgwtun -j ACCEPT" ; then iptables -A INPUT -i pgwtun -j ACCEPT; fi && \
    if ! iptables-save | grep -- "-A POSTROUTING -s 45.45.0.0/16 ! -o pgwtun -j MASQUERADE" ; then iptables -t nat -A POSTROUTING -s 45.45.0.0/16 ! -o pgwtun -j MASQUERADE; fi && \
    if ls /sys/class/net | grep "pgwtun" ; then ip link delete pgwtun; fi && \
    ip tuntap add name pgwtun mode tun && ip addr add 45.45.0.1/16 dev pgwtun && \
    ip link set dev pgwtun mtu 1400 && \
    ip addr add cafe::1/64 dev pgwtun && ip link set pgwtun up && \
    sleep 20 && ./nextepc-epcd

