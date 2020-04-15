#!/bin/bash
cd /opt/OpenIMSCore/FHoSS
sed -i 's|FHOSS_IP|'$FHOSS_IP'|g' ./config/hss.properties
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' ./config/hibernate.properties 
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' ./deploy/hibernate.properties 
sed -i 's|FHOSS_IP|'$FHOSS_IP'|g' ./config/DiameterPeerHSS.xml 
sed -i 's|FHOSS_IP|'$FHOSS_IP'|g' ./deploy/DiameterPeerHSS.xml

while true; do
	echo 'Waiting for MySQL to start.'
	echo '' | nc -w 1 $MYSQL_IP 3306 && break
	sleep 1
done

/hss.sh
