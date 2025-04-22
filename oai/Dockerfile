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

FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

# Install updates and dependencies
RUN apt-get update && \
    apt-get -y install build-essential cmake git subversion software-properties-common apt-utils unzip xxd iproute2
# Install dependencies to build SoapySDR and Lime Suite
RUN add-apt-repository -y ppa:myriadrf/drivers && \
    apt update && \
    apt -y install libi2c-dev libusb-1.0-0-dev git g++ cmake libsqlite3-dev libwxgtk3.0-gtk3-dev freeglut3-dev \
    python3-distutils gnuplot libfltk1.3-dev liboctave-dev libz-dev

# Install LimeSuite
RUN git clone https://github.com/myriadrf/LimeSuite.git && \
    cd LimeSuite && \
    git checkout tags/v23.11.0 -b v23.11.0 && \
    mkdir builddir && cd builddir && \
    cmake ../ && make && make install && \
    ldconfig

# Cloning RAN repository (eNB RAN + UE RAN)
RUN git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git && \
    cd openairinterface5g/ && git checkout develop

# Set the working directory to openairinterface5g
WORKDIR openairinterface5g

ARG SDRPLATFORM

RUN . ./oaienv && cd cmake_targets && \
    if [ "$SDRPLATFORM" != "LIMESDR" ] && [ "$SDRPLATFORM" != "BLADERF" ] && [ "$SDRPLATFORM" != "USRP" ]; then export SDRPLATFORM=USRP; fi && \
    apt-get -y install libsimde-dev && sed -i "s|install_simde_from_source $1|#install_simde_from_source $1|" ./tools/build_helper && \ 
    if [ "$SDRPLATFORM" = "LIMESDR" ]; then \
    ./build_oai -I -w LMSSDR --gNB --eNB --verbose-compile --disable-T-Tracer; \
    elif [ "$SDRPLATFORM" = "USRP" ]; then \
    export BUILD_UHD_FROM_SOURCE=True && export UHD_VERSION=4.7.0.0 && \
    ./build_oai -I -w USRP --gNB --eNB --verbose-compile; \
    elif [ "$SDRPLATFORM" = "BLADERF" ]; then \
    sed -i "s|timestamp -=|ptimestamp -=|" /openairinterface5g/radio/BLADERF/bladerf_lib.c && \
    ./build_oai -I -w BLADERF --gNB --eNB --verbose-compile --disable-hardware-dependency; \
    fi

CMD . ./oaienv && /mnt/oai/oai_init.sh && cd /openairinterface5g/cmake_targets/ran_build/build && \
    if [ "$SDRPLATFORM" = "LIMESDR" ]; then \
    if [ "$RADIO" = "LTE" ]; then \
    ./lte-softmodem -O $OPENAIR_DIR/targets/PROJECTS/GENERIC-LTE-EPC/CONF/enb.conf --rf-config-file $OPENAIR_DIR/radio/LMSSDR/LimeSDR.ini -d --opt.type wireshark; \
    elif [ "$RADIO" = "NR" ]; then \
    ./nr-softmodem -O $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.conf --sa --rf-config-file $OPENAIR_DIR/radio/LMSSDR/LimeSDR.ini -d --opt.type wireshark; \
    fi;\
    elif [ "$SDRPLATFORM" = "USRP" ] || ["$SDRPLATFORM" = "BLADERF" ]; then \
    if [ "$RADIO" = "LTE" ]; then \
    ./lte-softmodem -O $OPENAIR_DIR/targets/PROJECTS/GENERIC-LTE-EPC/CONF/enb.conf -d --opt.type wireshark; \    
    elif [ "$RADIO" = "NR" ]; then \
    ./nr-softmodem -O $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.conf --sa -d --opt.type wireshark; \
    fi;\
    fi
