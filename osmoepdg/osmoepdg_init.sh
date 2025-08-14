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

mkdir -p /usr/local/etc/swanctl
mkdir -p /usr/local/etc/strongswan.d
mkdir -p /usr/local/etc/strongswan.d/charon
mkdir -p /etc/osmocom
cp /mnt/osmoepdg/osmo-epdg.config /etc/osmocom
cp /mnt/osmoepdg/swanctl/swanctl.conf /etc/swanctl/swanctl.conf
cp /mnt/osmoepdg/strongswan.d/charon/kernel-netlink.conf /etc/strongswan.d/charon/kernel-netlink.conf
cp /mnt/osmoepdg/eap-aka.conf /etc/strongswan.d/charon/eap-aka.conf

OSMOEPDG_COMMA_SEPARATED_IP="${OSMOEPDG_IP//./,}"

export COMPONENT_NAME=osmoepdg
export IPSEC_TRAFFIC_FWMARK=2
export GTP_TRAFFIC_FWMARK=4
export EPDG_TUN_INTERFACE=gtp0
export EPDG_ROUTING_TABLE_NUMBER=2
export EPDG_ROUTING_TABLE_NAME=epdg

sed -i 's|OSMOEPDG_IP|'$OSMOEPDG_IP'|g' /etc/osmocom/osmo-epdg.config
sed -i 's|OSMOEPDG_COMMA_SEPARATED_IP|'$OSMOEPDG_COMMA_SEPARATED_IP'|g' /etc/osmocom/osmo-epdg.config
sed -i 's|HSS_IP|'$HSS_IP'|g' /etc/osmocom/osmo-epdg.config
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' /etc/osmocom/osmo-epdg.config
sed -i 's|SMF_IP|'$SMF_IP'|g' /etc/osmocom/osmo-epdg.config
sed -i 's|EPDG_TUN_INTERFACE|'$EPDG_TUN_INTERFACE'|g' /etc/osmocom/osmo-epdg.config
sed -i 's|GTP_TRAFFIC_FWMARK|'$GTP_TRAFFIC_FWMARK'|g' /etc/strongswan.d/charon/kernel-netlink.conf
sed -i 's|GTP_TRAFFIC_FWMARK|'$GTP_TRAFFIC_FWMARK'|g' /etc/swanctl/swanctl.conf
sed -i 's|OSMOEPDG_IP|'$OSMOEPDG_IP'|g' /etc/swanctl/swanctl.conf
sed -i 's|IPSEC_TRAFFIC_FWMARK|'$IPSEC_TRAFFIC_FWMARK'|g' /etc/swanctl/swanctl.conf

# Clear logs from previous runs
cat /dev/null > /mnt/osmoepdg/log/console.log
cat /dev/null > /mnt/osmoepdg/log/error.log
cat /dev/null > /mnt/osmoepdg/log/erlang.log
cat /dev/null > /mnt/osmoepdg/log/crash.log

# Start strongSwan
ipsec start --nofork &

# Wait for charon to create the VICI socket
sleep 2
chmod 660 /var/run/charon.vici

# Load config via swanctl
swanctl --load-all

# Create routing table entry
grep -qE "^${EPDG_ROUTING_TABLE_NUMBER} ${EPDG_ROUTING_TABLE_NAME}$" /etc/iproute2/rt_tables || \
    echo "${EPDG_ROUTING_TABLE_NUMBER} ${EPDG_ROUTING_TABLE_NAME}" >> /etc/iproute2/rt_tables

# Start configuration script in background
/mnt/osmoepdg/configure_interface.sh &

# Configure ipsec fwmark (nft)
cp /mnt/osmoepdg/nftables.conf /etc/nftables.conf
sed -i 's|EPDG_TUN_INTERFACE|'$EPDG_TUN_INTERFACE'|g' /etc/nftables.conf
sed -i 's|GTP_TRAFFIC_FWMARK|'$GTP_TRAFFIC_FWMARK'|g' /etc/nftables.conf
sed -i 's|IPSEC_TRAFFIC_FWMARK|'$IPSEC_TRAFFIC_FWMARK'|g' /etc/nftables.conf
nft -f /etc/nftables.conf

# Start osmo-epdg
cd /mnt/osmoepdg
export ERL_FLAGS="-config /etc/osmocom/osmo-epdg.config"
exec /osmo-epdg/_build/default/bin/osmo-epdg $@

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
