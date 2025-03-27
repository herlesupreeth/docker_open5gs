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

export IP_ADDR=$(awk 'END{print $1}' /etc/hosts)

mkdir -p /etc/srsran

if [[ -z "$COMPONENT_NAME" ]]; then
	echo "Error: COMPONENT_NAME environment variable not set"; exit 1;
elif [[ "$COMPONENT_NAME" =~ ^(gnb[[:digit:]]*$) ]]; then
	echo "Configuring component: '$COMPONENT_NAME'"
	cp /mnt/srsran/${COMPONENT_NAME}.yml /etc/srsran/gnb.yml
elif [[ "$COMPONENT_NAME" =~ ^(gnb_zmq[[:digit:]]*$) ]]; then
	echo "Configuring component: '$COMPONENT_NAME'"
	cp /mnt/srsran/${COMPONENT_NAME}.yml /etc/srsran/gnb.yml
else
	echo "Error: Invalid component name: '$COMPONENT_NAME'"
fi

cp /mnt/srsran/low_latency.yml /etc/srsran/low_latency.yml
cp /mnt/srsran/mimo_usrp.yml /etc/srsran/mimo_usrp.yml
cp /mnt/srsran/qam256.yml /etc/srsran/qam256.yml
cp /mnt/srsran/qos.yml /etc/srsran/qos.yml

sed -i 's|PLMN|'$MCC''$MNC'|g' /etc/srsran/gnb.yml
sed -i 's|AMF_IP|'$AMF_IP'|g' /etc/srsran/gnb.yml
sed -i 's|SRS_GNB_IP|'$SRS_GNB_IP'|g' /etc/srsran/gnb.yml
sed -i 's|SRS_UE_IP|'$SRS_UE_IP'|g' /etc/srsran/gnb.yml

# For dbus not started issue when host machine is running Ubuntu 22.04
service dbus start && service avahi-daemon start

extra_args=""

if [[ "$ENABLE_USRP_MIMO" == true ]]; then
	extra_args+=" -c /etc/srsran/mimo_usrp.yml"
fi
if [[ "$ENABLE_LOW_LATENCY" == true ]]; then
	extra_args+=" -c /etc/srsran/low_latency.yml"
fi
if [[ "$ENABLE_QAM256" == true ]]; then
	extra_args+=" -c /etc/srsran/qam256.yml"
fi

exec gnb -c /etc/srsran/gnb.yml -c /etc/srsran/qos.yml $extra_args $@

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
