FROM ubuntu:bionic

# Install updates and dependencies
RUN apt-get update && \
    apt-get -y install python3-pip python3-setuptools python3-wheel \
                    build-essential flex bison git libsctp-dev libgnutls28-dev \
                    libgcrypt-dev libssl-dev libidn11-dev libbson-dev \
                    libyaml-dev vim ifupdown curl gnupg iptables net-tools \
                    iputils-ping

# Dependencies of Kamailio
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install libxml2-dev libmysqlclient-dev libmnl-dev \
		mysql-server tcpdump screen ntp ntpdate dkms make \
		libcurl4-openssl-dev libpcre3-dev bash-completion \
		ipsec-tools libradcli-dev libradcli4

RUN git clone https://github.com/herlesupreeth/kamailio && \
    cd kamailio && \
    git checkout -b 5.3 origin/5.3

COPY modules.lst /tmp/

# Compile kamailio
WORKDIR /kamailio
ENV RADCLI=1
RUN make cfg && \
    cp /tmp/modules.lst ./src/ && \
    make -j4 Q=0 all | tee make_all.txt && \
    make install | tee make_install.txt && \
    ldconfig
RUN adduser --quiet --system --group --disabled-password --shell /bin/false --gecos "Kamailio" --home /var/run/kamailio kamailio && \
    chown kamailio:kamailio /var/run/kamailio
