#!/bin/bash

loop() {
	while true; do
		sleep 1
	done
}

while true; do
	echo 'Waiting for MySQL to start.'
	echo '' | nc -w 1 $MYSQL_IP 3306 && break
	sleep 1
done

sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/kamailio_icscf/kamailio_icscf.cfg
sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/kamailio_icscf/icscf.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/kamailio_icscf/icscf.cfg
sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/kamailio_icscf/icscf.xml

/etc/init.d/kamailio_icscf start && loop
