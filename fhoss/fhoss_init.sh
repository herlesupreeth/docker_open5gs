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

cp /mnt/fhoss/configurator.sh /opt/OpenIMSCore/FHoSS/deploy
cp /mnt/fhoss/DiameterPeerHSS.xml /opt/OpenIMSCore/FHoSS/deploy
cp /mnt/fhoss/hibernate.properties /opt/OpenIMSCore/FHoSS/deploy
cp /mnt/fhoss/configurator.sh /opt/OpenIMSCore/FHoSS/scripts
cp /mnt/fhoss/configurator.sh /opt/OpenIMSCore/FHoSS/config

cd /opt/OpenIMSCore/FHoSS/deploy && ./configurator.sh ${IMS_DOMAIN} ${FHOSS_IP}
sed -i 's|open-ims.org|'$IMS_DOMAIN'|g' /opt/OpenIMSCore/FHoSS/deploy/webapps/hss.web.console/WEB-INF/web.xml
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /opt/OpenIMSCore/FHoSS/deploy/hibernate.properties
sed -i 's|FHOSS_IP|'$FHOSS_IP'|g' /opt/OpenIMSCore/FHoSS/deploy/DiameterPeerHSS.xml
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /opt/OpenIMSCore/FHoSS/deploy/DiameterPeerHSS.xml
cd /opt/OpenIMSCore/FHoSS/scripts && ./configurator.sh ${IMS_DOMAIN} ${FHOSS_IP}
cd /opt/OpenIMSCore/FHoSS/config && ./configurator.sh ${IMS_DOMAIN} ${FHOSS_IP}
sed -i 's|open-ims.org|'$IMS_DOMAIN'|g' /opt/OpenIMSCore/FHoSS/src-web/WEB-INF/web.xml

while ! mysqladmin ping -h ${MYSQL_IP} --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 10;

# Create FHoSS database, populate tables and grant privileges
if [[ -z "`mysql -u root -h ${MYSQL_IP} -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='hss_db'" 2>&1`" ]];
then
	mysql -u root -h ${MYSQL_IP} -e "create database hss_db;"
	mysql -u root -h ${MYSQL_IP} hss_db < /opt/OpenIMSCore/FHoSS/scripts/hss_db.sql
	FHOSS_USER_EXISTS=`mysql -u root -h ${MYSQL_IP} -s -N -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User = 'hss' AND Host = '%')"`
	if [[ "$FHOSS_USER_EXISTS" == 0 ]]
	then
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'hss'@'%' IDENTIFIED WITH mysql_native_password BY 'hss'";
		mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'hss'@'$FHOSS_IP' IDENTIFIED WITH mysql_native_password BY 'hss'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON hss_db.* TO 'hss'@'%'";
		mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON hss_db.* TO 'hss'@'$FHOSS_IP'";
		mysql -u root -h ${MYSQL_IP} -e "FLUSH PRIVILEGES;"
	fi
	mysql -u root -h ${MYSQL_IP} hss_db < /opt/OpenIMSCore/FHoSS/scripts/userdata.sql
fi

VIS_NET_PRESENT=`mysql -u root -h ${MYSQL_IP} hss_db -s -N -e "SELECT count(*) FROM visited_network;"`
if [[ "$VIS_NET_PRESENT" -gt 0 ]]
then
	mysql -u root -h ${MYSQL_IP} hss_db -e "DELETE FROM visited_network;"
	mysql -u root -h ${MYSQL_IP} hss_db -e "INSERT INTO visited_network VALUES (1, '$IMS_DOMAIN');"
fi

PREF_SCSCF_PRESENT=`mysql -u root -h ${MYSQL_IP} hss_db -s -N -e "SELECT count(*) FROM preferred_scscf_set;"`
if [[ "$PREF_SCSCF_PRESENT" -gt 0 ]]
then
	mysql -u root -h ${MYSQL_IP} hss_db -e "DELETE FROM preferred_scscf_set;"
	mysql -u root -h ${MYSQL_IP} hss_db -e "INSERT INTO preferred_scscf_set VALUES (1, 1, 'scscf1', 'sip:scscf.$IMS_DOMAIN:6060', 0);"
fi

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

cp /mnt/fhoss/hss.sh /
cd / && ./hss.sh
