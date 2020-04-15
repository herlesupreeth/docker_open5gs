FROM ubuntu:bionic

# Install updates and dependencies
RUN apt-get update && \
    apt-get -y install curl net-tools iputils-ping wget subversion

WORKDIR /usr/local/src
COPY jdk-checksum /usr/local/src
RUN wget https://files-cdn.liferay.com/mirrors/download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz
RUN apt-get -y install libdigest-sha-perl
RUN shasum -c jdk-checksum
RUN mkdir -p /usr/lib/jvm/ && \
    tar zxf jdk-7u80-linux-x64.tar.gz -C /usr/lib/jvm/ && \
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.7.0_80/bin/java 100 && \
    update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.7.0_80/bin/javac 100

WORKDIR /usr/local
RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.14-bin.tar.gz
RUN tar zxf apache-ant-1.9.14-bin.tar.gz && \
    echo ANT_HOME=/usr/local/  >> /etc/environment && \
    ln -s /usr/local/apache-ant-1.9.14/bin/ant /usr/bin/ant

RUN mkdir -p /opt/OpenIMSCore && \
    cd /opt/OpenIMSCore && \
    svn checkout svn://svn.code.sf.net/p/openimscore/code/FHoSS/trunk && \
    mv trunk FHoSS

WORKDIR /opt/OpenIMSCore/FHoSS
ENV JAVA_HOME="/usr/lib/jvm/jdk1.7.0_80"
ENV CLASSPATH="/usr/lib/jvm/jdk1.7.0_80/jre/lib/"
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"
RUN ant compile deploy | tee ant_compile_deploy.txt

ADD deploy /opt/OpenIMSCore/FHoSS/deploy/
ADD config /opt/OpenIMSCore/FHoSS/config/
ADD scripts /opt/OpenIMSCore/FHoSS/scripts/
COPY hss.sh /

RUN apt-get install -y netcat

EXPOSE 3868/udp
EXPOSE 3868/tcp
EXPOSE 3868/sctp
EXPOSE 5868/udp
EXPOSE 5868/tcp
EXPOSE 5868/sctp
EXPOSE 8080/tcp

CMD /mnt/fhoss/fhoss_init.sh
