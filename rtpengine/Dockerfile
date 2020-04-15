FROM ubuntu:bionic

RUN apt-get update && \
    apt-get install -y debhelper default-libmysqlclient-dev gperf iptables-dev libavcodec-dev \
    		git libavfilter-dev libavformat-dev libavutil-dev libbencode-perl libcrypt-openssl-rsa-perl \
		libcrypt-rijndael-perl libdigest-crc-perl libdigest-hmac-perl libevent-dev libhiredis-dev \
		libio-multiplex-perl libio-socket-inet6-perl libiptc-dev libjson-glib-dev libnet-interface-perl \
		libpcap0.8-dev libsocket6-perl libspandsp-dev libswresample-dev libsystemd-dev \
		libxmlrpc-core-c3-dev markdown dkms module-assistant keyutils libnfsidmap2 libtirpc1 \
		nfs-common rpcbind

ENV DEB_BUILD_PROFILES="pkg.ngcp-rtpengine.nobcg729"
RUN apt-get install -y dpkg-dev libcurl4-openssl-dev

RUN git clone https://github.com/sipwise/rtpengine && \
    cd rtpengine && \
    git checkout mr7.4.1

WORKDIR /rtpengine
RUN dpkg-checkbuilddeps && \
    dpkg-buildpackage -uc -us

# ngcp-rtpengine-utils depends on netcat
RUN cd .. && \
    apt-get install -y netcat iptables && \
    dpkg -i *.deb

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y linux-headers-$(uname -r) linux-image-$(uname -r) && \
    module-assistant update && \
    module-assistant auto-install ngcp-rtpengine-kernel-source

EXPOSE 2223/udp

CMD /mnt/rtpengine/rtpengine_init.sh
