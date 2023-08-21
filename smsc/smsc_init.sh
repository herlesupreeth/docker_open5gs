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

mkdir -p /etc/kamailio_smsc
cp /mnt/smsc/smsc.cfg /etc/kamailio_smsc
cp /mnt/smsc/kamailio_smsc.cfg /etc/kamailio_smsc

while ! mysqladmin ping -h ${MYSQL_IP} --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 10;

# Drop SMSC database
mysql -u root -h ${MYSQL_IP} -e "drop database smsc;"

# Create SMSC database, populate tables and grant privileges
if [[ -z "`mysql -u root -h ${MYSQL_IP} -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='smsc'" 2>&1`" ]];
then
	mysql -u root -h ${MYSQL_IP} -e "create database smsc;"
	mysql -u root -h ${MYSQL_IP} smsc < /usr/local/src/kamailio/utils/kamctl/mysql/standard-create.sql
	mysql -u root -h ${MYSQL_IP} smsc < /mnt/smsc/smsc-create.sql
	mysql -u root -h ${MYSQL_IP} smsc < /usr/local/src/kamailio/utils/kamctl/mysql/dialplan-create.sql
	mysql -u root -h ${MYSQL_IP} smsc < /usr/local/src/kamailio/utils/kamctl/mysql/presence-create.sql

	SMSC_USER_EXISTS=`mysql -u root -h ${MYSQL_IP} -s -N -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User = 'smsc' AND Host = '%')"`
	if [[ "$SMSC_USER_EXISTS" == 0 ]]
	then
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'smsc'@'%' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'smsc'@'$SMSC_IP' IDENTIFIED WITH mysql_native_password BY 'heslo'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON smsc.* TO 'smsc'@'%'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON smsc.* TO 'smsc'@'$SMSC_IP'";
		mysql -u root -h ${MYSQL_IP} -e "FLUSH PRIVILEGES;"
	fi
fi

sed -i 's|SMSC_IP|'$SMSC_IP'|g' /etc/kamailio_smsc/smsc.cfg
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/kamailio_smsc/smsc.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/kamailio_smsc/smsc.cfg

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
