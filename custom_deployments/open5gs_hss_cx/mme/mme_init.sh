#!/bin/bash

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

export IP_ADDR=$(awk 'END{print $1}' /etc/hosts)
export IF_NAME=$(ip r | awk '/default/ { print $5 }')

[ ${#MNC} == 3 ] && EPC_DOMAIN="epc.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || EPC_DOMAIN="epc.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

cp /mnt/mme/mme.yaml install/etc/open5gs
cp /mnt/mme/mme.conf install/etc/freeDiameter
cp /mnt/mme/make_certs.sh install/etc/freeDiameter

sed -i 's|MNC|'$MNC'|g' install/etc/open5gs/mme.yaml
sed -i 's|MCC|'$MCC'|g' install/etc/open5gs/mme.yaml
sed -i 's|TAC|'$TAC'|g' install/etc/open5gs/mme.yaml
sed -i 's|MME_IP|'$MME_IP'|g' install/etc/open5gs/mme.yaml
sed -i 's|MME_IF|'$IF_NAME'|g' install/etc/open5gs/mme.yaml
sed -i 's|OSMOMSC_IP|'$OSMOMSC_IP'|g' install/etc/open5gs/mme.yaml
sed -i 's|SGWC_IP|'$SGWC_IP'|g' install/etc/open5gs/mme.yaml
sed -i 's|SMF_IP|'$SMF_IP'|g' install/etc/open5gs/mme.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' install/etc/open5gs/mme.yaml
sed -i 's|MME_IP|'$MME_IP'|g' install/etc/freeDiameter/mme.conf
sed -i 's|HSS_IP|'$HSS_IP'|g' install/etc/freeDiameter/mme.conf
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' install/etc/freeDiameter/mme.conf
sed -i 's|HSS_BIND_PORT|'$HSS_BIND_PORT'|g' install/etc/freeDiameter/mme.conf
sed -i 's|LD_LIBRARY_PATH|'$LD_LIBRARY_PATH'|g' install/etc/freeDiameter/mme.conf
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' install/etc/freeDiameter/make_certs.sh

# Generate TLS certificates
./install/etc/freeDiameter/make_certs.sh install/etc/freeDiameter

cd install/bin
exec ./open5gs-mmed $@

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
