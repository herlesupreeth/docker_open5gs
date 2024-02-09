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

while ! mysqladmin ping -h ${MYSQL_IP} --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 10;

# Create IMS HSS database user
PYHSS_USER_EXISTS=`mysql -u root -h ${MYSQL_IP} -s -N -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User = 'pyhss' AND Host = '$PYHSS_IP')"`
if [[ "$PYHSS_USER_EXISTS" == 0 ]]
then
	mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'pyhss'@'%' IDENTIFIED WITH mysql_native_password BY 'ims_db_pass'";
	mysql -u root -h ${MYSQL_IP} -e "CREATE USER 'pyhss'@'$PYHSS_IP' IDENTIFIED WITH mysql_native_password BY 'ims_db_pass'";
	mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON *.* TO 'pyhss'@'%'";
	mysql -u root -h ${MYSQL_IP} -e "GRANT ALL ON *.* TO 'pyhss'@'$PYHSS_IP'";
	mysql -u root -h ${MYSQL_IP} -e "FLUSH PRIVILEGES;"
fi

[ ${#MNC} == 3 ] && EPC_DOMAIN="epc.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || EPC_DOMAIN="epc.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"
[ ${#MNC} == 3 ] && IMS_DOMAIN="ims.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || IMS_DOMAIN="ims.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

cp /mnt/pyhss/config.yaml ./
cp /mnt/pyhss/default_ifc.xml ./
cp /mnt/pyhss/default_sh_user_data.xml ./

INSTALL_PREFIX="/pyhss"

sed -i 's|PYHSS_IP|'$PYHSS_IP'|g' ./config.yaml
sed -i 's|PYHSS_BIND_PORT|'$PYHSS_BIND_PORT'|g' ./config.yaml
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' ./config.yaml
sed -i 's|OP_MCC|'$MCC'|g' ./config.yaml
sed -i 's|OP_MNC|'$MNC'|g' ./config.yaml
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' ./config.yaml
sed -i 's|INSTALL_PREFIX|'$INSTALL_PREFIX'|g' ./config.yaml

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

git apply /mnt/pyhss/database_fix.patch

redis-server --daemonize yes

cd services
python3 apiService.py --host=$PYHSS_IP --port=8080 &
# Sleep is needed to let db be populated in a non-overlapping fashion
sleep 5
python3 diameterService.py &
# Sleep is needed to let db be populated in a non-overlapping fashion
sleep 5
python3 hssService.py
