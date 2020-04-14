#!/bin/bash

mkdir -p /var/spool/rtpengine
cp /mnt/rtpengine/*.conf /etc/rtpengine/
modprobe xt_RTPENGINE
/usr/sbin/ngcp-rtpengine-iptables-setup start
/usr/sbin/rtpengine-recording -E --no-log-timestamps --pidfile /ngcp-rtpengine-recording-daemon.pid --config-file /etc/rtpengine/rtpengine-recording.conf
/usr/sbin/rtpengine -f -E --no-log-timestamps --pidfile ngcp-rtpengine-daemon.pid --config-file /etc/rtpengine/rtpengine.conf --table 0 --interface=$RTPENGINE_IP --listen-ng=$RTPENGINE_IP:2223
