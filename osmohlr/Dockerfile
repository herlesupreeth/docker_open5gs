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

FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV OSMOCOM_REPO="https://downloads.osmocom.org/packages/osmocom:/latest/Debian_11"

# Install updates and dependencies
RUN apt-get update && \
    apt-get -y install wget gnupg telnet

RUN wget $OSMOCOM_REPO/Release.key && \
    mv Release.key /etc/apt/trusted.gpg.d/osmocom-latest.asc && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/osmocom-latest.asc] $OSMOCOM_REPO/ ./" > /etc/apt/sources.list.d/osmocom-latest.list && \
    apt-get update && apt-get install -f && apt-get --install-suggests -y install osmo-hlr

CMD /mnt/osmohlr/osmohlr_init.sh && \
    cd /mnt/osmohlr && /usr/bin/osmo-hlr -c /etc/osmocom/osmo-hlr.cfg
