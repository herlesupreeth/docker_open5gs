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

[ ${#MNC} == 3 ] && EPC_DOMAIN="epc.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || EPC_DOMAIN="epc.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"
export NODENAME=ocs@$EPC_DOMAIN

if test -z "$RELDIR"; then
	export RELDIR=$HOME/releases
fi
START_ERL_DATA=$RELDIR/start_erl.data
RELEASENAME=`sed 's/^.* //' $START_ERL_DATA`

cp /mnt/ocs/start ./bin/
cp /mnt/ocs/sys.config ./releases/$RELEASENAME/

OCS_COMMA_SEPARATED_IP="${OCS_IP//./,}"
SMF_COMMA_SEPARATED_IP="${SMF_IP//./,}"

sed -i 's|OCS_IP|'$OCS_IP'|g' ./releases/$RELEASENAME/sys.config
sed -i 's|OCS_COMMA_SEPARATED_IP|'$OCS_COMMA_SEPARATED_IP'|g' ./releases/$RELEASENAME/sys.config
sed -i 's|SMF_COMMA_SEPARATED_IP|'$SMF_COMMA_SEPARATED_IP'|g' ./releases/$RELEASENAME/sys.config
sed -i 's|SMF_IF|'$SMF_IF'|g' ./releases/$RELEASENAME/sys.config
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' ./releases/$RELEASENAME/sys.config
sed -i 's|OCS_BIND_PORT|'$OCS_BIND_PORT'|g' ./releases/$RELEASENAME/sys.config
sed -i 's|RELEASENAME|'$RELEASENAME'|g' ./releases/$RELEASENAME/sys.config

./bin/initialize

exec ./bin/start $@

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
