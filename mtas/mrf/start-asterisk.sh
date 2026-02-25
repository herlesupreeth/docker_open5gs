#!/bin/bash


[ ${#MNC} == 3 ] && IMS_DOMAIN="ims.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || IMS_DOMAIN="ims.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

cp /mnt/mrf/config/*.conf /etc/asterisk/
cp /mnt/mrf/config/odbc* /etc/

sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/pjsip.conf
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/extensions.conf
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/voicemail.conf
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/extensions.conf
sed -i 's|MYSQL_MTAS_IP|'$MYSQL_MTAS_IP'|g' /etc/odbc.ini
sed -i 's|MYSQL_MTAS_PORT|'$MYSQL_MTAS_PORT'|g' /etc/odbc.ini

# Start server.
echo 'Starting Asterisk'

asterisk -f