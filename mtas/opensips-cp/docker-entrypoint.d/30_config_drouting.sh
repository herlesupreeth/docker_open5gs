#!/bin/bash

cd "$(dirname "$0")"
. functions

echo "Configuring OpenSIPS CP Dynamic Routing Tool..."

add_parameter drouting tabs "'gateways.php,carriers.php,rules.php'"
add_parameter drouting group_ids_file "'{\"1\":\"Default\"}'"
add_parameter drouting gw_attributes_mode "'none'"
add_parameter drouting carrier_attributes_mode "'none'"
