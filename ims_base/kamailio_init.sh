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

if [[ -z "$COMPONENT_NAME" ]]; then
	echo "Error: COMPONENT_NAME environment variable not set"; exit 1;
elif [[ "$COMPONENT_NAME" =~ ^(icscf-[[:digit:]]+$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	/mnt/icscf/icscf_init.sh && \
	mkdir -p /var/run/kamailio_icscf && \
	kamailio -f /etc/kamailio_icscf/kamailio_icscf.cfg -P /kamailio_icscf.pid -DD -E -e
elif [[ "$COMPONENT_NAME" =~ ^(scscf-[[:digit:]]+$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	/mnt/scscf/scscf_init.sh && \
	mkdir -p /var/run/kamailio_scscf && \
	kamailio -f /etc/kamailio_scscf/kamailio_scscf.cfg -P /kamailio_scscf.pid -DD -E -e
elif [[ "$COMPONENT_NAME" =~ ^(pcscf-[[:digit:]]+$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	/mnt/pcscf/pcscf_init.sh && \
	mkdir -p /var/run/kamailio_pcscf && \
	kamailio -f /etc/kamailio_pcscf/kamailio_pcscf.cfg -P /kamailio_pcscf.pid -DD -E -e
elif [[ "$COMPONENT_NAME" =~ ^(smsc-[[:digit:]]+$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	/mnt/smsc/smsc_init.sh && \
	mkdir -p /var/run/kamailio_smsc && \
	kamailio -f /etc/kamailio_smsc/kamailio_smsc.cfg -P /kamailio_smsc.pid -DD -E -e
else
	echo "Error: Invalid component name: '$COMPONENT_NAME'"
fi
