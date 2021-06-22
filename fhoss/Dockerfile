# THIRD PARTY SOFTWARE NOTICES AND INFORMATION
# Do Not Translate or Localize
# 
# This repository includes Oracle Java 7 JDK downloaded from Oracle website, which is distributed 
# under Oracle Binary Code License Agreement for Java SE. By using this repository you agree to 
# have reviewed and accepted the Oracle Binary Code License Agreement for Java SE and hold
# no liability.
# 
# =========================================

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
	apt-get -y install git vim wget subversion mysql-server

# Install Oracle Java 7 SE JDK
RUN mkdir -p  /usr/lib/jvm/ && \
	cd / && wget https://files-cdn.liferay.com/mirrors/download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz && \
	tar -zxf /jdk-7u80-linux-x64.tar.gz -C /usr/lib/jvm/ && \
	update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.7.0_80/bin/java 100 && \
	update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.7.0_80/bin/javac 100

# Install Ant
RUN cd / && wget http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.14-bin.tar.gz && \
	tar xvfvz apache-ant-1.9.14-bin.tar.gz && \
	mv apache-ant-1.9.14 /usr/local/ && \
	ln -s /usr/local/apache-ant-1.9.14/bin/ant /usr/bin/ant

RUN mkdir -p /opt/OpenIMSCore && \
	cd /opt/OpenIMSCore && \
	git clone https://github.com/herlesupreeth/FHoSS

ENV JAVA_HOME="/usr/lib/jvm/jdk1.7.0_80"
ENV CLASSPATH="/usr/lib/jvm/jdk1.7.0_80/jre/lib/"
ENV ANT_HOME="/usr/local/apache-ant-1.9.14"
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN	cd /opt/OpenIMSCore/FHoSS && \
	ant compile deploy | tee ant_compile_deploy.txt

CMD /mnt/fhoss/fhoss_init.sh
