# docker_open5gs
Quite contrary to the name of the repository, this repository contains docker files to deploy an Over-The-Air (OTA) or RF simulated 4G/5G network using following projects:
- Core Network (4G/5G) - open5gs - https://github.com/open5gs/open5gs
- IMS (Only 4G supported i.e. VoLTE) - kamailio
- IMS HSS - https://github.com/nickvsnetworking/pyhss
- Osmocom HLR - https://github.com/osmocom/osmo-hlr
- Osmocom MSC - https://github.com/osmocom/osmo-msc
- srsRAN (4G/5G) - https://github.com/srsran/srsRAN
- UERANSIM (5G) - https://github.com/aligungr/UERANSIM

## Tested Setup

Docker host machine

- Ubuntu 20.04 or 22.04

Over-The-Air setups: 

- srsRAN (eNB/gNB) using Ettus USRP B210
- srsRAN eNB using LimeSDR Mini v1.3
- srsRAN eNB using LimeSDR-USB

RF simulated setups:

 - srsRAN (gNB + UE) simulation over ZMQ
 - UERANSIM (gNB + UE) simulator

## Build and Execution Instructions

* Mandatory requirements:
	* [docker-ce](https://docs.docker.com/install/linux/docker-ce/ubuntu) - Version 22.0.5 or above
	* [docker-compose](https://docs.docker.com/compose) - Version 2.14 or above


Clone repository and build base docker image of open5gs, kamailio, ueransim

```
git clone https://github.com/herlesupreeth/docker_open5gs
cd docker_open5gs/base
docker build --no-cache --force-rm -t docker_open5gs .

cd ../ims_base
docker build --no-cache --force-rm -t docker_kamailio .

cd ../srslte
docker build --no-cache --force-rm -t docker_srslte .

cd ../srsran
docker build --no-cache --force-rm -t docker_srsran .

cd ../ueransim
docker build --no-cache --force-rm -t docker_ueransim .
```

### Build and Run using docker-compose

```
cd ..
set -a
source .env
docker-compose build --no-cache
docker-compose up

Over-The-Air setups: 

# srsRAN eNB using SDR
docker-compose -f srsenb.yaml up -d && docker attach srsenb
# srsRAN gNB using SDR
docker-compose -f srsgnb.yaml up -d && docker attach srsgnb

RF simulated setups:

# srsRAN ZMQ eNB
docker-compose -f srsenb_zmq.yaml up -d && docker attach srsenb_zmq
# srsRAN ZMQ gNB
docker-compose -f srsgnb_zmq.yaml up -d && docker attach srsgnb_zmq
# srsRAN ZMQ 4G UE
docker-compose -f srsue_zmq.yaml up -d && docker attach srsue_zmq
# srsRAN ZMQ 5G UE
docker-compose -f srsue_5g_zmq.yaml up -d && docker attach srsue_5g_zmq
# UERANSIM gNB
docker-compose -f nr-gnb.yaml up -d && docker attach nr_gnb
# UERANSIM NR-UE
docker-compose -f nr-ue.yaml up -d && docker attach nr_ue
```

## Configuration

For the quick run (eNB/gNB, CN in same docker network), edit only the following parameters in .env as per your setup

```
MCC
MNC
TEST_NETWORK --> Change this only if it clashes with the internal network at your home/office
DOCKER_HOST_IP --> This is the IP address of the host running your docker setup
SGWU_ADVERTISE_IP --> Change this to value of DOCKER_HOST_IP set above only if eNB is not running the same docker network/host
UPF_ADVERTISE_IP --> Change this to value of DOCKER_HOST_IP set above only if gNB is not running the same docker network/host
UE_IPV4_INTERNET --> Change this to your desired (Not conflicted) UE network ip range for internet APN
UE_IPV4_IMS --> Change this to your desired (Not conflicted) UE network ip range for ims APN
```

If eNB/gNB is NOT running in the same docker network/host as the host running the dockerized Core/IMS then follow the below additional steps

Under mme section in docker compose file (**docker-compose.yaml**), uncomment the following part
```
...
    # ports:
    #   - "36412:36412/sctp"
...
```

Under amf section in docker compose file (**docker-compose.yaml**, **sa-deploy.yaml**), uncomment the following part
```
...
    # ports:
    #   - "38412:38412/sctp"
...
```

If deploying in 5G mode only (**sa-deploy.yaml**), then uncomment the following part under **upf** section
```
...
    # ports:
    #   - "2152:2152/udp"
...
```

If deploying in 4G mode only (**docker-compose.yaml**), then uncomment the following part under **sgwu** section
```
...
    # ports:
    #   - "2152:2152/udp"
...
```

## Provisioning of UE information

Open (http://<DOCKER_HOST_IP>:3000) in a web browser, where <DOCKER_HOST_IP> is the IP of the machine/VM running the open5gs containers. Login with following credentials
```
Username : admin
Password : 1423
```

Using Web UI, add a subscriber

## Not supported
- IPv6 usage in Docker
