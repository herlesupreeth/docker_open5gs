#!/bin/bash
envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < /etc/opensips/opensips-cli.tmpl > /etc/opensips/opensips-cli.cfg
envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" | m4 /etc/opensips/global.m4 -

