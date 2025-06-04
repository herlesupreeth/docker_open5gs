#!/bin/bash

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

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export IP_ADDR=$(awk 'END{print $1}' /etc/hosts)
export IF_NAME=$(ip r | awk '/default/ { print $5 }')

[ ${#MNC} == 3 ] && EPC_DOMAIN="epc.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || EPC_DOMAIN="epc.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

UE_IPV4_INTERNET_TUN_IP=$(python3 /mnt/smf/ip_utils.py --ip_range $UE_IPV4_INTERNET)
UE_IPV4_IMS_TUN_IP=$(python3 /mnt/smf/ip_utils.py --ip_range $UE_IPV4_IMS)

cp /mnt/smf/smf.yaml install/etc/open5gs
if [[ ${DEPLOY_MODE} == 4G ]];
then
    cp /mnt/smf/smf_4g.yaml install/etc/open5gs/smf.yaml
fi
cp /mnt/smf/smf.conf install/etc/freeDiameter
cp /mnt/smf/make_certs.sh install/etc/freeDiameter

sed -i 's|SMF_IP|'$SMF_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|SCP_IP|'$SCP_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|NRF_IP|'$NRF_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|UPF_IP|'$UPF_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|SMF_DNS1|'$SMF_DNS1'|g' install/etc/open5gs/smf.yaml
sed -i 's|SMF_DNS2|'$SMF_DNS2'|g' install/etc/open5gs/smf.yaml
sed -i 's|UE_IPV4_INTERNET_TUN_IP|'$UE_IPV4_INTERNET_TUN_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|UE_IPV4_INTERNET_SUBNET|'$UE_IPV4_INTERNET'|g' install/etc/open5gs/smf.yaml
sed -i 's|UE_IPV4_IMS_TUN_IP|'$UE_IPV4_IMS_TUN_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|UE_IPV4_IMS_SUBNET|'$UE_IPV4_IMS'|g' install/etc/open5gs/smf.yaml
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' install/etc/open5gs/smf.yaml
sed -i 's|SMF_IP|'$SMF_IP'|g' install/etc/freeDiameter/smf.conf
sed -i 's|PCRF_IP|'$PCRF_IP'|g' install/etc/freeDiameter/smf.conf
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' install/etc/freeDiameter/smf.conf
sed -i 's|PCRF_BIND_PORT|'$PCRF_BIND_PORT'|g' install/etc/freeDiameter/smf.conf
sed -i 's|LD_LIBRARY_PATH|'$LD_LIBRARY_PATH'|g' install/etc/freeDiameter/smf.conf
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' install/etc/freeDiameter/make_certs.sh
sed -i 's|OCS_BIND_PORT|'$OCS_BIND_PORT'|g' install/etc/freeDiameter/smf.conf
sed -i 's|OCS_IP|'$OCS_IP'|g' install/etc/freeDiameter/smf.conf

# Generate TLS certificates
./install/etc/freeDiameter/make_certs.sh install/etc/freeDiameter

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
