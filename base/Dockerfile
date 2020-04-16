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
RUN apt-get update && \
    apt-get -y install python3-pip python3-setuptools python3-wheel ninja-build \
                    build-essential flex bison git libsctp-dev libgnutls28-dev \
                    libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev \
                    libyaml-dev meson vim ifupdown mongodb curl gnupg gdb iptables net-tools \
                    iputils-ping
RUN pip3 install click
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs && \
    apt-get autoremove -y && apt-get clean

# Get open5gs code and install
RUN git clone --recursive https://github.com/open5gs/open5gs && cd open5gs && \
    git checkout tags/v1.2.3 && meson build --prefix=`pwd`/install && \
    ninja -C build && cd build && ninja install

# Choose this one if you want to use Herle Supreeth's *no IPv6 hack*
#RUN git clone --recursive https://github.com/herlesupreeth/open5gs && cd open5gs && \
#    git checkout hacks && meson build --prefix=`pwd`/install && \
#    ninja -C build && cd build && ninja install

# Set the working directory to open5gs
WORKDIR open5gs

# Building WebUI of open5gs
RUN cd webui && npm install
