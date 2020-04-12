#!/bin/bash
docker run -it --rm --privileged -v "$(pwd)":/mnt/srsenb -v /dev/bus/usb:/dev/bus/usb --net docker_open5gs_default --ip 172.18.0.7 --name srsenb docker_srsenb 
