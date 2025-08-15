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

# Install required packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        lsb-release \
        ca-certificates \
        git \
        vim \
        wget \
        curl \
        openssh-server \
        net-tools \
    && apt-get clean
RUN apt --no-install-recommends --assume-yes install unzip autoconf automake build-essential pkg-config libedit-dev libjansson-dev libsqlite3-dev uuid-dev libxslt1-dev xmlstarlet \
    && apt clean

# Download Asterisk source :
WORKDIR /usr/src
RUN git clone -b releases/22 https://github.com/asterisk/asterisk.git
# Adding EVS and AMR support
# First EVS 
WORKDIR /usr/src/asterisk
# install additional DEBs required by Asterisk
RUN sh contrib/scripts/install_prereq install
RUN sh contrib/scripts/get_mp3_source.sh
RUN git clone https://github.com/NUCLEAR-WAR/asterisk-evs.git
RUN cp --verbose --recursive ./asterisk-evs*/* ./
RUN patch -p0 <./codec_evs.patch
RUN wget www.etsi.org/deliver/etsi_ts/126400_126499/126443/16.01.00_60/ts_126443v160100p0.zip
RUN unzip -qq ts_126443v*.zip
RUN unzip -qq 26443-*-ANSI-C_source_code.zip
WORKDIR /usr/src/asterisk/c-code
RUN chmod +r ./lib_*/*.h
RUN mkdir /usr/include/3gpp-evs
RUN cp --verbose --target-directory=/usr/include/3gpp-evs ./lib_*/*.h
RUN DEBUG=0 RELEASE=1 CFLAGS='-DNDEBUG -fPIC' make
WORKDIR /usr/src/asterisk/c-code/build
RUN rm ./decoder.o
RUN cc -shared -o lib3gpp-evs.so *.o
RUN cp ./lib3gpp-evs.so /usr/lib/
WORKDIR /usr/src/asterisk
RUN patch -p0 <./build_evs.patch
RUN patch -p0 <./force_limitations.patch

# Now AMR
RUN apt --assume-yes install libopencore-amrnb-dev libopencore-amrwb-dev libvo-amrwbenc-dev
RUN wget github.com/traud/asterisk-amr/archive/master.zip
RUN unzip -qq master.zip
RUN rm master.zip
RUN cp --verbose --recursive ./asterisk-amr*/* ./
RUN patch -p0 <./codec_amr.patch
RUN patch -p0 <./build_tools.patch

# Run the bootstrap script to re-generate configure files and configure patched Asterisk:
RUN ./bootstrap.sh
RUN ./configure
COPY menuselect.makedeps .
COPY menuselect.makeopts .
RUN make && make install

COPY config/* /etc/asterisk/

CMD ["/mnt/ibcf/start-asterisk.sh"]
