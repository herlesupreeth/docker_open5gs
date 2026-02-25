#!/bin/bash

cd "$(dirname "$0")"
. functions

echo "Configuring OpenSIPS CP Alias Management Tool ..."

add_parameter alias_management table_aliases "'{\"DIDs\":\"dids\"}'"
add_parameter alias_management implicit_domain '1'
add_parameter alias_management suppress_alias_type '1'
