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

[ ${#MNC} == 3 ] && IMS_DOMAIN="ims.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || IMS_DOMAIN="ims.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

cp /mnt/ibcf/config/* /etc/asterisk/

sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/pjsip.conf
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/extensions.conf
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/voicemail.conf

# Add static route to route traffic back to UE as there is not NATing
ip r add ${UE_IPV4_IMS} via ${UPF_IP}

# Start server.
echo 'Starting Asterisk'

asterisk -f
