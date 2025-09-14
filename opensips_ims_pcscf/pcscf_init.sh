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

sh -c "echo 1 > /proc/sys/net/ipv4/ip_nonlocal_bind"
sh -c "echo 1 > /proc/sys/net/ipv6/ip_nonlocal_bind"

[ ${#MNC} == 3 ] && EPC_DOMAIN="epc.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || EPC_DOMAIN="epc.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"
[ ${#MNC} == 3 ] && IMS_DOMAIN="ims.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || IMS_DOMAIN="ims.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

mkdir -p /etc/opensips
cp /mnt/pcscf/freeDiameter.conf /etc/opensips
cp /mnt/pcscf/pcscf.dictionary /etc/opensips
cp /mnt/pcscf/opensips.cfg /etc/opensips
cp -r /mnt/pcscf/db /etc/opensips

# For mi_fifo module.
mkdir -p /var/run/opensips

if [[ ${DEPLOY_MODE} == 5G ]];
then
	cp /mnt/pcscf/opensips_vonr.cfg /etc/opensips/opensips.cfg
fi

while ! mysqladmin ping -h ${MYSQL_IP} --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 10;

# Create PCSCF database, populate tables and grant privileges
if [[ -z "`mysql -u root -h ${MYSQL_IP} -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='opensips_pcscf'" 2>&1`" ]];
then
	mysql -u root -h ${MYSQL_IP} -e "create database opensips_pcscf;"
	mysql -u root -h ${MYSQL_IP} opensips_pcscf < /usr/local/share/opensips/mysql/standard-create.sql
	mysql -u root -h ${MYSQL_IP} opensips_pcscf < /usr/local/share/opensips/mysql/presence-create.sql
	PCSCF_USER_EXISTS=`mysql -u root -h ${MYSQL_IP} -s -N -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User = 'opensips_pcscf' AND Host = '%')"`
	if [[ "$PCSCF_USER_EXISTS" == 0 ]]
	then
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'opensips_pcscf'@'%' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'opensips_pcscf'@'$PCSCF_IP' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON opensips_pcscf.* TO 'opensips_pcscf'@'%'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON opensips_pcscf.* TO 'opensips_pcscf'@'$PCSCF_IP'";
		mysql -u root -h ${MYSQL_IP} -e "FLUSH PRIVILEGES;"
	fi
fi


sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/opensips/opensips.cfg
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/opensips/opensips.cfg
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' /etc/opensips/opensips.cfg
sed -i 's|SCSCF_IP|'$SCSCF_IP'|g' /etc/opensips/opensips.cfg
sed -i 's|RTPENGINE_IP|'$RTPENGINE_IP'|g' /etc/opensips/opensips.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/opensips/opensips.cfg

sed -i 's|PCRF_BIND_PORT|'$PCRF_BIND_PORT'|g' /etc/opensips/freeDiameter.conf
sed -i 's|PCSCF_BIND_PORT|'$PCSCF_BIND_PORT'|g' /etc/opensips/freeDiameter.conf
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/opensips/freeDiameter.conf
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' /etc/opensips/freeDiameter.conf
sed -i 's|PCRF_IP|'$PCRF_IP'|g' /etc/opensips/freeDiameter.conf
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/opensips/freeDiameter.conf

# Add static route to route traffic back to UE as there is not NATing
ip r add ${UE_IPV4_IMS} via ${UPF_IP}
# Route needed for VoWiFi client where internet APN is used
ip r add ${UE_IPV4_INTERNET} via ${UPF_IP}

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

exec opensips -f /etc/opensips/opensips.cfg -F $@
