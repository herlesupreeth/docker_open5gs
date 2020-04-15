#!/bin/bash

sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/kamailio_pcscf/kamailio_pcscf.cfg
sed -i 's|RTPENGINE_IP|'$RTPENGINE_IP'|g' /etc/kamailio_pcscf/kamailio_pcscf.cfg
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/kamailio_pcscf/pcscf.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/kamailio_pcscf/pcscf.cfg
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/kamailio_pcscf/pcscf.xml

DAEMON=/usr/local/sbin/kamailio
NAME=kamailio_pcscf
HOMEDIR=/var/run/$NAME
PIDFILE=$HOMEDIR/$NAME.pid
CFGFILE=/etc/$NAME/$NAME.cfg
USER=kamailio
GROUP=kamailio
SHM_MEMORY=64
PKG_MEMORY=8
DUMP_CORE=no

mkdir -p $HOMEDIR

set +e
out=$($DAEMON -f $CFGFILE -M $PKG_MEMORY -c 2>&1 > /dev/null)
retcode=$?
set -e
if [ "$retcode" != '0' ]; then
    echo "Not starting $DESC: invalid configuration file!"
    echo "$out"
    exit 1
fi

RADIUS_SEQ_FILE="$HOMEDIR/kamailio_radius.seq"
chown ${USER}:${GROUP} $HOMEDIR

if [ ! -f $RADIUS_SEQ_FILE ]; then
    touch $RADIUS_SEQ_FILE
fi

chown ${USER}:${GROUP} $RADIUS_SEQ_FILE
chmod 660 $RADIUS_SEQ_FILE

$DAEMON -f $CFGFILE -P $PIDFILE -D -E -e