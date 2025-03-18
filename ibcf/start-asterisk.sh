#!/bin/bash


[ ${#MNC} == 3 ] && IMS_DOMAIN="ims.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || IMS_DOMAIN="ims.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

cp /mnt/ibcf/config/* /etc/asterisk/

sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/pjsip.conf
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/extensions.conf
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/voicemail.conf
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/asterisk/extensions.conf

# Start server.
echo 'Starting Asterisk'

asterisk -f