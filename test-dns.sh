#!/bin/bash
set -a
. .env
set +a

host hss.epc.mnc001.mcc001.3gppnetwork.org. $DNS_IP
host mme.epc.mnc001.mcc001.3gppnetwork.org. $DNS_IP
host pcrf.epc.mnc001.mcc001.3gppnetwork.org. $DNS_IP
host ims.mnc001.mcc001.3gppnetwork.org. $DNS_IP
host pcscf.ims.mnc001.mcc001.3gppnetwork.org. $DNS_IP
host -t SRV _sip._udp.pcscf.ims.mnc001.mcc001.3gppnetwork.org $DNS_IP
host -t SRV _sip._tcp.scscf.ims.mnc001.mcc001.3gppnetwork.org $DNS_IP
