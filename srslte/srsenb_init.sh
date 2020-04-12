#!/bin/bash

mkdir -p /etc/srslte
cp /srsLTE/*.conf /etc/srslte/
set -a
. /mnt/srsenb/.env
set +a

sed -i 's|MME_IP|'$MME_IP'|g' /etc/srslte/enb.conf
sed -i 's|ENB_IP|'$ENB_IP'|g' /etc/srslte/enb.conf
sed -i 's|DL_EARFCN|'$DL_EARFCN'|g' /etc/srslte/enb.conf
