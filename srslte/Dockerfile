FROM ubuntu:bionic

# Install updates and dependencies
RUN apt-get update && \
    apt-get -y install cmake libfftw3-dev libmbedtls-dev libboost-program-options-dev libconfig++-dev libsctp-dev
RUN apt-get -y install git

# Install Ettus USRP (UHD)
RUN apt-get -y install libuhd-dev libuhd003.010.003 uhd-host --no-install-recommends && \
    /usr/bin/uhd_images_downloader

# Get srsLTE and compile
RUN git clone https://github.com/srsLTE/srsLTE.git && \
    cd srsLTE && \
    git checkout tags/release_19_12

WORKDIR /srsLTE

RUN mkdir build && \
    mkdir /etc/srslte && \
    cd build && \
    cmake ../ && \
    make -j4 && \
    make install && \
    ldconfig

COPY conf/*.conf /srsLTE/

EXPOSE 2152/udp
EXPOSE 2123/udp

CMD /mnt/srsenb/srsenb_init.sh  && \
    /usr/local/bin/srsenb
