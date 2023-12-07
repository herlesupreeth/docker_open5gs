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

cp /mnt/srslte/rb.conf /etc/srsran
cp /mnt/srslte/sib.conf /etc/srsran

if [[ -z "$COMPONENT_NAME" ]]; then
	echo "Error: COMPONENT_NAME environment variable not set"; exit 1;
elif [[ "$COMPONENT_NAME" =~ ^(gnb$) ]]; then
	echo "Configuring component: '$COMPONENT_NAME'"
	cp /mnt/srslte/rr_gnb.conf /etc/srsran/rr.conf
	cp /mnt/srslte/enb.conf /etc/srsran
	sed -i 's|MME_IP|'$AMF_IP'|g' /etc/srsran/enb.conf
elif [[ "$COMPONENT_NAME" =~ ^(enb$) ]]; then
	echo "Configuring component: '$COMPONENT_NAME'"
	cp /mnt/srslte/rr.conf /etc/srsran
	cp /mnt/srslte/enb.conf /etc/srsran
	sed -i 's|MME_IP|'$MME_IP'|g' /etc/srsran/enb.conf
elif [[ "$COMPONENT_NAME" =~ ^(enb_zmq$) ]]; then
	echo "Configuring component: '$COMPONENT_NAME'"
	cp /mnt/srslte/rr.conf /etc/srsran
	cp /mnt/srslte/enb_zmq.conf /etc/srsran/enb.conf
	sed -i 's|MME_IP|'$MME_IP'|g' /etc/srsran/enb.conf
elif [[ "$COMPONENT_NAME" =~ ^(gnb_zmq$) ]]; then
	echo "Configuring component: '$COMPONENT_NAME'"
	cp /mnt/srslte/rr_gnb_zmq.conf /etc/srsran/rr.conf
	cp /mnt/srslte/gnb_zmq.conf /etc/srsran/enb.conf
	sed -i 's|MME_IP|'$AMF_IP'|g' /etc/srsran/enb.conf
elif [[ "$COMPONENT_NAME" =~ ^(ue_zmq$) ]]; then
	echo "Configuring component: '$COMPONENT_NAME'"
	cp /mnt/srslte/ue_zmq.conf /etc/srsran/ue.conf
elif [[ "$COMPONENT_NAME" =~ ^(ue_5g_zmq$) ]]; then
	echo "Configuring component: '$COMPONENT_NAME'"
	cp /mnt/srslte/ue_5g_zmq.conf /etc/srsran/ue.conf
else
	echo "Error: Invalid component name: '$COMPONENT_NAME'"
fi

sed -i 's|MNC|'$MNC'|g' /etc/srsran/enb.conf
sed -i 's|MCC|'$MCC'|g' /etc/srsran/enb.conf
sed -i 's|SRS_ENB_IP|'$SRS_ENB_IP'|g' /etc/srsran/enb.conf
sed -i 's|SRS_UE_IP|'$SRS_UE_IP'|g' /etc/srsran/enb.conf
sed -i 's|UE1_KI|'$UE1_KI'|g' /etc/srsran/ue.conf
sed -i 's|UE1_OP|'$UE1_OP'|g' /etc/srsran/ue.conf
sed -i 's|UE1_IMSI|'$UE1_IMSI'|g' /etc/srsran/ue.conf
sed -i 's|SRS_UE_IP|'$SRS_UE_IP'|g' /etc/srsran/ue.conf
sed -i 's|SRS_ENB_IP|'$SRS_ENB_IP'|g' /etc/srsran/ue.conf
sed -i 's|SRS_GNB_IP|'$SRS_GNB_IP'|g' /etc/srsran/ue.conf

# For dbus not started issue when host machine is running Ubuntu 22.04
service dbus start && service avahi-daemon start

if [[ -z "$COMPONENT_NAME" ]]; then
	echo "Error: COMPONENT_NAME environment variable not set"; exit 1;
elif [[ "$COMPONENT_NAME" =~ ^(gnb$) || "$COMPONENT_NAME" =~ ^(enb$) || "$COMPONENT_NAME" =~ ^(enb_zmq$) || "$COMPONENT_NAME" =~ ^(gnb_zmq$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	/usr/local/bin/srsenb
elif [[ "$COMPONENT_NAME" =~ ^(ue_zmq$) || "$COMPONENT_NAME" =~ ^(ue_5g_zmq$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	/usr/local/bin/srsue
else
	echo "Error: Invalid component name: '$COMPONENT_NAME'"
fi

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
