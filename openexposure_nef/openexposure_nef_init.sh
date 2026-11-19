#!/bin/sh
set -eu

: "${NEF_IP:?NEF_IP must be set}"
: "${PCF_IP:?PCF_IP must be set}"

# Only substitute deployment addresses; leave the mounted template untouched.
mkdir -p /etc/openexposure_nef
envsubst '${NEF_IP} ${PCF_IP}' < /mnt/openexposure_nef/asSessionWithQos.yaml > /etc/openexposure_nef/config.yaml

# Compose dependency ordering does not mean the PCF listener is ready.
attempt=0
until nc -z -w 1 "$PCF_IP" 7777; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 30 ]; then
        echo "NEF: PCF at $PCF_IP:7777 did not become reachable after 30 attempts" >&2
        exit 1
    fi
    sleep 1
done

exec /as-sess-qos -c /etc/openexposure_nef/config.yaml "$@"
