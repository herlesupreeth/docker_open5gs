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

[ ${#MNC} == 3 ] && IMS_DOMAIN="ims.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || IMS_DOMAIN="ims.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"
[ ${#MNC} == 3 ] && EPC_DOMAIN="epc.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || EPC_DOMAIN="epc.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

mkdir -p /etc/kamailio_icscf
cp /mnt/icscf/icscf.cfg /etc/kamailio_icscf
cp /mnt/icscf/icscf.xml /etc/kamailio_icscf
cp /mnt/icscf/kamailio_icscf.cfg /etc/kamailio_icscf

while ! mysqladmin ping -h ${MYSQL_IP} --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 10;

# Create ICSCF database, populate tables and grant privileges
if [[ -z "`mysql -u root -h ${MYSQL_IP} -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='icscf'" 2>&1`" ]];
then
	mysql -u root -h ${MYSQL_IP} -e "create database icscf;"
	mysql -u root -h ${MYSQL_IP} icscf < /usr/local/src/kamailio/misc/examples/ims/icscf/icscf.sql

	ICSCF_USER_EXISTS=`mysql -u root -h ${MYSQL_IP} -s -N -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User = 'icscf' AND Host = '%')"`
	if [[ "$ICSCF_USER_EXISTS" == 0 ]]
	then
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'icscf'@'%' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'provisioning'@'%' IDENTIFIED WITH mysql_native_password BY 'provi'";
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'icscf'@'$ICSCF_IP' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'provisioning'@'$ICSCF_IP' IDENTIFIED WITH mysql_native_password BY 'provi'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON icscf.* TO 'icscf'@'%'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON icscf.* TO 'icscf'@'$ICSCF_IP'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON icscf.* TO 'provisioning'@'%'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON icscf.* TO 'provisioning'@'$ICSCF_IP'";
		mysql -u root -h ${MYSQL_IP} -e "FLUSH PRIVILEGES;"
	fi
fi

DOMAIN_PRESENT=`mysql -u root -h ${MYSQL_IP} icscf -s -N -e "SELECT count(*) FROM nds_trusted_domains WHERE trusted_domain='$IMS_DOMAIN';"`
if [[ "$DOMAIN_PRESENT" == 0 ]]
then
	mysql -u root -h ${MYSQL_IP} icscf -e "INSERT INTO nds_trusted_domains (trusted_domain) VALUES ('$IMS_DOMAIN');"
fi

URI_PRESENT=`mysql -u root -h ${MYSQL_IP} icscf -s -N -e "SELECT count(*) FROM s_cscf WHERE s_cscf_uri='sip:scscf.$IMS_DOMAIN:6060';"`
if [[ "$URI_PRESENT" == 0 ]]
then
	mysql -u root -h ${MYSQL_IP} icscf -e "INSERT INTO s_cscf (name, s_cscf_uri) VALUES ('First and only S-CSCF', 'sip:scscf.$IMS_DOMAIN:6060');"
fi

SCSCF_ID=`mysql -u root -h ${MYSQL_IP} icscf -s -N -e "SELECT id FROM s_cscf WHERE s_cscf_uri='sip:scscf.$IMS_DOMAIN:6060' LIMIT 1;"`
CAP_PRESENT=`mysql -u root -h ${MYSQL_IP} icscf -s -N -e "SELECT count(*) FROM s_cscf_capabilities WHERE id_s_cscf='$SCSCF_ID';"`
if [[ "$CAP_PRESENT" == 0 ]]
then
	mysql -u root -h ${MYSQL_IP} icscf -e "INSERT INTO s_cscf_capabilities (id_s_cscf, capability) VALUES ('$SCSCF_ID', 0),('$SCSCF_ID', 1);"
fi

SUBSCRIPTION_EXPIRES_ENV=3600

sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/kamailio_icscf/icscf.cfg
sed -i 's|SUBSCRIPTION_EXPIRES_ENV|'$SUBSCRIPTION_EXPIRES_ENV'|g' /etc/kamailio_icscf/icscf.cfg
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/kamailio_icscf/icscf.cfg
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' /etc/kamailio_icscf/icscf.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/kamailio_icscf/icscf.cfg

sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/kamailio_icscf/icscf.xml
sed -i 's|SUBSCRIPTION_EXPIRES_ENV|'$SUBSCRIPTION_EXPIRES_ENV'|g' /etc/kamailio_icscf/icscf.xml
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/kamailio_icscf/icscf.xml
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' /etc/kamailio_icscf/icscf.xml
sed -i 's|HSS_BIND_PORT|'$HSS_BIND_PORT'|g' /etc/kamailio_icscf/icscf.xml
sed -i 's|ICSCF_BIND_PORT|'$ICSCF_BIND_PORT'|g' /etc/kamailio_icscf/icscf.xml

mkdir -p /var/run/kamailio_icscf
rm -f /kamailio_icscf.pid
exec kamailio -f /etc/kamailio_icscf/kamailio_icscf.cfg -P /kamailio_icscf.pid -DD -E -e $@

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
