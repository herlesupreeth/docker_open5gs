#!/bin/bash

cp /mnt/dns/dnsmasq.conf /etc/
set -a
. /mnt/dns/.env
set +a

sed -i 's|HSS_IP|'$HSS_IP'|g' /etc/dnsmasq.conf
sed -i 's|MME_IP|'$MME_IP'|g' /etc/dnsmasq.conf
sed -i 's|SGW_IP|'$SGW_IP'|g' /etc/dnsmasq.conf
sed -i 's|PGW_IP|'$PGW_IP'|g' /etc/dnsmasq.conf
sed -i 's|PCRF_IP|'$PCRF_IP'|g' /etc/dnsmasq.conf
sed -i 's|ENB_IP|'$ENB_IP'|g' /etc/dnsmasq.conf
sed -i 's|DNS_IP|'$DNS_IP'|g' /etc/dnsmasq.conf
sed -i 's|MONGO_IP|'$MONGO_IP'|g' /etc/dnsmasq.conf
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/dnsmasq.conf
sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/dnsmasq.conf
sed -i 's|SCSCF_IP|'$SCSCF_IP'|g' /etc/dnsmasq.conf
sed -i 's|FHOSS_IP|'$FHOSS_IP'|g' /etc/dnsmasq.conf

/usr/sbin/dnsmasq -d
