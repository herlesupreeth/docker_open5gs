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

cp /mnt/oai/enb.band7.tm1.50PRB.usrpb210.conf $OPENAIR_DIR/targets/PROJECTS/GENERIC-LTE-EPC/CONF/
cp /mnt/oai/gnb.sa.band78.fr1.106PRB.usrpb210.conf $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/
cp /mnt/oai/gnb.sa.band41.fr1.52PRB.usrpb210.conf $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/

[ ${#MNC} == 3 ] && MNC_LEN=3 || MNC_LEN=2

ENB_CONF_FILE="enb.band7.tm1.50PRB.usrpb210.conf"
GNB_CONF_FILE="gnb.sa.band41.fr1.52PRB.usrpb210.conf"

sed -i 's|MNC_LEN|'$MNC_LEN'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-LTE-EPC/CONF/$ENB_CONF_FILE
sed -i 's|MNC|'$MNC'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-LTE-EPC/CONF/$ENB_CONF_FILE
sed -i 's|MCC|'$MCC'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-LTE-EPC/CONF/$ENB_CONF_FILE
sed -i 's|OAI_ENB_IF|'$IF_NAME'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-LTE-EPC/CONF/$ENB_CONF_FILE
sed -i 's|OAI_ENB_IP|'$OAI_ENB_IP'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-LTE-EPC/CONF/$ENB_CONF_FILE
sed -i 's|MME_IP|'$MME_IP'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-LTE-EPC/CONF/$ENB_CONF_FILE

sed -i 's|MNC_LEN|'$MNC_LEN'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/$GNB_CONF_FILE
sed -i 's|MNC|'$MNC'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/$GNB_CONF_FILE
sed -i 's|MCC|'$MCC'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/$GNB_CONF_FILE
sed -i 's|OAI_ENB_IF|'$IF_NAME'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/$GNB_CONF_FILE
sed -i 's|OAI_ENB_IP|'$OAI_ENB_IP'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/$GNB_CONF_FILE
sed -i 's|AMF_IP|'$AMF_IP'|g' $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/$GNB_CONF_FILE

cd cmake_targets/ran_build/build
if [[ -z "$COMPONENT_NAME" ]]; then
	echo "Error: COMPONENT_NAME environment variable not set"; exit 1;
elif [[ "$COMPONENT_NAME" =~ ^(oaignb[[:digit:]]*$) ]]; then
	echo "Configuring component: '$COMPONENT_NAME'"
	exec ./nr-softmodem -O $OPENAIR_DIR/targets/PROJECTS/GENERIC-NR-5GC/CONF/$GNB_CONF_FILE --sa -d $@
elif [[ "$COMPONENT_NAME" =~ ^(oaienb[[:digit:]]*$) ]]; then
	echo "Configuring component: '$COMPONENT_NAME'"
	exec ./lte-softmodem -O $OPENAIR_DIR/targets/PROJECTS/GENERIC-LTE-EPC/CONF/$ENB_CONF_FILE -d $@
else
	echo "Error: Invalid component name: '$COMPONENT_NAME'"
fi

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
