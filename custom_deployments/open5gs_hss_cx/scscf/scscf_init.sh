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

mkdir -p /etc/kamailio_scscf
cp /mnt/scscf/scscf.cfg /etc/kamailio_scscf
cp /mnt/scscf/scscf.xml /etc/kamailio_scscf
cp /mnt/scscf/kamailio_scscf.cfg /etc/kamailio_scscf
cp /mnt/scscf/CxDataType_Rel6.xsd /etc/kamailio_scscf
cp /mnt/scscf/CxDataType_Rel7.xsd /etc/kamailio_scscf
cp /mnt/scscf/CxDataType_Rel8.xsd /etc/kamailio_scscf
cp /mnt/scscf/dispatcher.list /etc/kamailio_scscf

while ! mysqladmin ping -h ${MYSQL_IP} --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 10;

# Create SCSCF database, populate tables and grant privileges
if [[ -z "`mysql -u root -h ${MYSQL_IP} -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='scscf'" 2>&1`" ]];
then
	mysql -u root -h ${MYSQL_IP} -e "create database scscf;"
	mysql -u root -h ${MYSQL_IP} scscf < /usr/local/src/kamailio/utils/kamctl/mysql/standard-create.sql
	mysql -u root -h ${MYSQL_IP} scscf < /usr/local/src/kamailio/utils/kamctl/mysql/presence-create.sql
	mysql -u root -h ${MYSQL_IP} scscf < /usr/local/src/kamailio/utils/kamctl/mysql/ims_usrloc_scscf-create.sql
	mysql -u root -h ${MYSQL_IP} scscf < /usr/local/src/kamailio/utils/kamctl/mysql/ims_dialog-create.sql
	mysql -u root -h ${MYSQL_IP} scscf < /usr/local/src/kamailio/utils/kamctl/mysql/ims_charging-create.sql
	SCSCF_USER_EXISTS=`mysql -u root -h ${MYSQL_IP} -s -N -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User = 'scscf' AND Host = '%')"`
	if [[ "$SCSCF_USER_EXISTS" == 0 ]]
	then
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'scscf'@'%' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'scscf'@'$SCSCF_IP' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON scscf.* TO 'scscf'@'%'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON scscf.* TO 'scscf'@'$SCSCF_IP'";
		mysql -u root -h ${MYSQL_IP} -e "FLUSH PRIVILEGES;"
	fi
fi

export IMS_SLASH_DOMAIN=`echo $IMS_DOMAIN | sed 's/\./\\\./g'`

SUBSCRIPTION_EXPIRES_ENV=3600

sed -i 's|SCSCF_IP|'$SCSCF_IP'|g' /etc/kamailio_scscf/scscf.cfg
sed -i 's|SUBSCRIPTION_EXPIRES_ENV|'$SUBSCRIPTION_EXPIRES_ENV'|g' /etc/kamailio_scscf/scscf.cfg
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/kamailio_scscf/scscf.cfg
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' /etc/kamailio_scscf/scscf.cfg
sed -i 's|IMS_SLASH_DOMAIN|'$IMS_SLASH_DOMAIN'|g' /etc/kamailio_scscf/scscf.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/kamailio_scscf/scscf.cfg

sed -i 's|SCSCF_IP|'$SCSCF_IP'|g' /etc/kamailio_scscf/scscf.xml
sed -i 's|SUBSCRIPTION_EXPIRES_ENV|'$SUBSCRIPTION_EXPIRES_ENV'|g' /etc/kamailio_scscf/scscf.xml
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/kamailio_scscf/scscf.xml
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' /etc/kamailio_scscf/scscf.xml
sed -i 's|HSS_BIND_PORT|'$HSS_BIND_PORT'|g' /etc/kamailio_scscf/scscf.xml
sed -i 's|SCSCF_BIND_PORT|'$SCSCF_BIND_PORT'|g' /etc/kamailio_scscf/scscf.xml

mkdir -p /var/run/kamailio_scscf
rm -f /kamailio_scscf.pid
exec kamailio -f /etc/kamailio_scscf/kamailio_scscf.cfg -P /kamailio_scscf.pid -DD -E -e $@

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
