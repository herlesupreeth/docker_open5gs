#!/bin/bash

while true; do
	echo 'Waiting for MySQL to start.'
	echo '' | nc -w 1 $MYSQL_IP 3306 && break
	sleep 1
done

sed -i 's|SCSCF_IP|'$SCSCF_IP'|g' /etc/kamailio_scscf/kamailio_scscf.cfg
sed -i 's|SCSCF_IP|'$SCSCF_IP'|g' /etc/kamailio_scscf/scscf.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/kamailio_scscf/scscf.cfg
sed -i 's|SCSCF_IP|'$SCSCF_IP'|g' /etc/kamailio_scscf/scscf.xml

/etc/init.d/kamailio_scscf start
