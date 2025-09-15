# docker_open5gs
Quite contrary to the name of the repository, this repository contains docker files to deploy an Over-The-Air (OTA) or RF simulated 4G/5G network using following projects:
- Core Network (4G/5G) - open5gs - https://github.com/open5gs/open5gs
- IMS (VoLTE + VoNR) - kamailio - https://github.com/kamailio/kamailio
- IMS HSS - https://github.com/nickvsnetworking/pyhss
- Osmocom HLR - https://github.com/osmocom/osmo-hlr
- Osmocom MSC - https://github.com/osmocom/osmo-msc
- srsRAN_4G (4G eNB + 4G UE + 5G UE) - https://github.com/srsran/srsRAN_4G
- srsRAN_Project (5G gNB) - https://github.com/srsran/srsRAN_Project
- UERANSIM (5G gNB + 5G UE) - https://github.com/aligungr/UERANSIM
- eUPF (5G UPF) - https://github.com/edgecomllc/eupf
- OpenSIPS IMS - https://github.com/OpenSIPS/opensips
- Sigscale OCS - https://github.com/sigscale/ocs
- Osmo-epdg + Strongswan-epdg
  - https://gitea.osmocom.org/erlang/osmo-epdg
  - https://gitea.osmocom.org/ims-volte-vowifi/strongswan-epdg
- SWu-IKEv2 - https://github.com/fasferraz/SWu-IKEv2

## Table of Contents

- [Tested Setup](#tested-setup)
- [Prepare Docker images](#prepare-docker-images)
  - [Get Pre-built Docker images](#get-pre-built-docker-images)
  - [Build Docker images from source](#build-docker-images-from-source)
- [Network and deployment configuration](#network-and-deployment-configuration)
  - [Single Host setup configuration](#single-host-setup-configuration)
  - [Multihost setup configuration](#multihost-setup-configuration)
    - [4G deployment](#4g-deployment)
    - [5G SA deployment](#5g-sa-deployment)
- [Network Deployment](#network-deployment)
- [Docker Compose files overview](#docker-compose-files-overview)
- [Provisioning of SIM information](#provisioning-of-sim-information)
  - [Provisioning of SIM information in open5gs HSS](#provisioning-of-sim-information-in-open5gs-hss-as-follows)
  - [Provisioning of IMSI and MSISDN with OsmoHLR](#provisioning-of-imsi-and-msisdn-with-osmohlr-as-follows)
  - [Provisioning of SIM information in pyHSS](#provisioning-of-sim-information-in-pyhss-is-as-follows)
  - [Provisioning of Diameter Peer + Subscriber information in Sigscale OCS](#provisioning-of-diameter-peer--subscriber-information-in-sigscale-ocs-as-follows-skip-if-ocs-is-not-deployed)
- [Testing VoWiFi with COTS UE](#testing-vowifi-with-cots-ue)
  - [Pre-requisites](#pre-requisites)
  - [Deploy the required components](#deploy-the-required-components)
  - [Provision SIM and IMS subscriber information](#provision-sim-and-ims-subscriber-information)
  - [Manually configure DNS settings on your phone (WiFi connection)](#manually-configure-dns-settings-on-your-phone-wifi-connection)
  - [UE configuration](#ue-configuration)
- [Not supported](#not-supported)

## Tested Setup

Docker host machine

- Ubuntu 22.04 or above

Over-The-Air setups: 

- srsRAN_Project gNB using Ettus USRP B210
- srsRAN_Project (5G gNB) using LibreSDR (USRP B210 clone)
- srsRAN_4G eNB using LimeSDR Mini v1.3
- srsRAN_4G eNB using LimeSDR-USB
- srsRAN_4G eNB using LibreSDR (USRP B210 clone)

RF simulated setups:

- srsRAN_4G (eNB + UE) simulation over ZMQ
- srsRAN_Project (5G gNB) + srsRAN_4G (5G UE) simulation over ZMQ
- UERANSIM (gNB + UE) simulator

## Prepare Docker images

* Mandatory requirements:
	* [docker-ce](https://docs.docker.com/install/linux/docker-ce/ubuntu) - Version 22.0.5 or above
	* [docker compose](https://docs.docker.com/compose) - Version 2.14 or above

You can either pull the pre-built docker images or build them from the source.

### Get Pre-built Docker images

Pull base images:
```
docker pull ghcr.io/herlesupreeth/docker_open5gs:master
docker tag ghcr.io/herlesupreeth/docker_open5gs:master docker_open5gs

docker pull ghcr.io/herlesupreeth/docker_grafana:master
docker tag ghcr.io/herlesupreeth/docker_grafana:master docker_grafana

docker pull ghcr.io/herlesupreeth/docker_metrics:master
docker tag ghcr.io/herlesupreeth/docker_metrics:master docker_metrics
```

You can also pull the pre-built images for additional components

For IMS components:
```
docker pull ghcr.io/herlesupreeth/docker_osmohlr:master
docker tag ghcr.io/herlesupreeth/docker_osmohlr:master docker_osmohlr

docker pull ghcr.io/herlesupreeth/docker_osmomsc:master
docker tag ghcr.io/herlesupreeth/docker_osmomsc:master docker_osmomsc

docker pull ghcr.io/herlesupreeth/docker_pyhss:master
docker tag ghcr.io/herlesupreeth/docker_pyhss:master docker_pyhss

docker pull ghcr.io/herlesupreeth/docker_kamailio:master
docker tag ghcr.io/herlesupreeth/docker_kamailio:master docker_kamailio

docker pull ghcr.io/herlesupreeth/docker_mysql:master
docker tag ghcr.io/herlesupreeth/docker_mysql:master docker_mysql

docker pull ghcr.io/herlesupreeth/docker_opensips:master
docker tag ghcr.io/herlesupreeth/docker_opensips:master docker_opensips
```

For srsRAN components:
```
docker pull ghcr.io/herlesupreeth/docker_srslte:master
docker tag ghcr.io/herlesupreeth/docker_srslte:master docker_srslte

docker pull ghcr.io/herlesupreeth/docker_srsran:master
docker tag ghcr.io/herlesupreeth/docker_srsran:master docker_srsran
```

For UERANSIM components:
```
docker pull ghcr.io/herlesupreeth/docker_ueransim:master
docker tag ghcr.io/herlesupreeth/docker_ueransim:master docker_ueransim
```

For EUPF component:
```
docker pull ghcr.io/herlesupreeth/docker_eupf:master
docker tag ghcr.io/herlesupreeth/docker_eupf:master docker_eupf
```

For Sigscale OCS component:
```
docker pull ghcr.io/herlesupreeth/docker_ocs:master
docker tag ghcr.io/herlesupreeth/docker_ocs:master docker_ocs
```

For Osmo-epdg + Strongswan-epdg component:
```
docker pull ghcr.io/herlesupreeth/docker_osmoepdg:master
docker tag ghcr.io/herlesupreeth/docker_osmoepdg:master docker_osmoepdg
```

For SWu-IKEv2 component:
```
docker pull ghcr.io/herlesupreeth/docker_swu_client:master
docker tag ghcr.io/herlesupreeth/docker_swu_client:master docker_swu_client
```

### Build Docker images from source
#### Clone repository and build base docker image of open5gs, kamailio, srsRAN_4G, srsRAN_Project, ueransim

```
# Build docker image for open5gs EPC/5GC components
git clone https://github.com/herlesupreeth/docker_open5gs
cd docker_open5gs/base
docker build --no-cache --force-rm -t docker_open5gs .

# Build docker image for kamailio IMS components
cd ../ims_base
docker build --no-cache --force-rm -t docker_kamailio .

# Build docker image for srsRAN_4G eNB + srsUE (4G+5G)
cd ../srslte
docker build --no-cache --force-rm -t docker_srslte .

# Build docker image for srsRAN_Project gNB
cd ../srsran
docker build --no-cache --force-rm -t docker_srsran .

# Build docker image for UERANSIM (gNB + UE)
cd ../ueransim
docker build --no-cache --force-rm -t docker_ueransim .

# Build docker image for EUPF
cd ../eupf
docker build --no-cache --force-rm -t docker_eupf .

# Build docker image for OpenSIPS IMS
cd ../opensips_ims_base
docker build --no-cache --force-rm -t docker_opensips .

# Build docker image for Osmo-epdg + Strongswan-epdg
cd ../osmoepdg
docker build --no-cache --force-rm -t docker_osmoepdg .

# Build docker image for SWu-IKEv2
cd ../swu_client
docker build --no-cache --force-rm -t docker_swu_client .
```

#### Build docker images for additional components

```
cd ..
set -a
source .env
set +a
sudo ufw disable
sudo sysctl -w net.ipv4.ip_forward=1
sudo cpupower frequency-set -g performance

# For 4G deployment only
docker compose -f 4g-volte-deploy.yaml build

# For 5G deployment only
docker compose -f sa-deploy.yaml build
```

## Network and deployment configuration

The setup can be mainly deployed in two ways:

1. Single host setup where eNB/gNB and (EPC+IMS)/5GC are deployed on a single host machine
2. Multi host setup where eNB/gNB is deployed on a separate host machine than (EPC+IMS)/5GC

### Single Host setup configuration
Edit only the following parameters in **.env** as per your setup

```
MCC
MNC
DOCKER_HOST_IP --> This is the IP address of the host running your docker setup
UE_IPV4_INTERNET --> Change this to your desired (Not conflicted) UE network ip range for internet APN
UE_IPV4_IMS --> Change this to your desired (Not conflicted) UE network ip range for ims APN
```

### Multihost setup configuration

#### 4G deployment

###### On the host running the (EPC+IMS)

Edit only the following parameters in **.env** as per your setup
```
MCC
MNC
DOCKER_HOST_IP --> This is the IP address of the host running (EPC+IMS)
SGWU_ADVERTISE_IP --> Change this to value of DOCKER_HOST_IP
UE_IPV4_INTERNET --> Change this to your desired (Not conflicted) UE network ip range for internet APN
UE_IPV4_IMS --> Change this to your desired (Not conflicted) UE network ip range for ims APN
```

Under **mme** section in docker compose file (**4g-volte-deploy.yaml**), uncomment the following part
```
...
    # ports:
    #   - "36412:36412/sctp"
...
```

Then, uncomment the following part under **sgwu** section
```
...
    # ports:
    #   - "2152:2152/udp"
...
```

###### On the host running the eNB

Edit only the following parameters in **.env** as per your setup
```
MCC
MNC
DOCKER_HOST_IP --> This is the IP address of the host running eNB
MME_IP --> Change this to IP address of host running (EPC+IMS)
SRS_ENB_IP --> Change this to the IP address of the host running eNB
```

Replace the following part in the docker compose file (**srsenb.yaml**)
```
    networks:
      default:
        ipv4_address: ${SRS_ENB_IP}
networks:
  default:
    external:
      name: docker_open5gs_default
```
with 
```
	network_mode: host
```

#### 5G SA deployment

###### On the host running the 5GC

Edit only the following parameters in **.env** as per your setup
```
MCC
MNC
DOCKER_HOST_IP --> This is the IP address of the host running 5GC
UPF_ADVERTISE_IP --> Change this to value of DOCKER_HOST_IP
UE_IPV4_INTERNET --> Change this to your desired (Not conflicted) UE network ip range for internet APN
UE_IPV4_IMS --> Change this to your desired (Not conflicted) UE network ip range for ims APN
```

Under **amf** section in docker compose file (**sa-deploy.yaml**), uncomment the following part
```
...
    # ports:
    #   - "38412:38412/sctp"
...
```

Then, uncomment the following part under **upf** section
```
...
    # ports:
    #   - "2152:2152/udp"
...
```

###### On the host running the gNB

Edit only the following parameters in **.env** as per your setup
```
MCC
MNC
DOCKER_HOST_IP --> This is the IP address of the host running gNB
AMF_IP --> Change this to IP address of host running 5GC
SRS_GNB_IP --> Change this to the IP address of the host running gNB
```

Replace the following part in the docker compose file (**srsgnb.yaml**)
```
    networks:
      default:
        ipv4_address: ${SRS_GNB_IP}
networks:
  default:
    external: true
    name: docker_open5gs_default
```
with 
```
	network_mode: host
```

## Network Deployment

###### 4G deployment

```
# 4G Core Network + IMS + SMS over SGs (uses Kamailio IMS)
docker compose -f 4g-volte-deploy.yaml up

# 4G Core Network + IMS + SMS over SGs (uses openSIPS IMS)
docker compose -f 4g-volte-opensips-ims-deploy.yaml up

# srsRAN eNB using SDR (OTA)
docker compose -f srsenb.yaml up -d && docker container attach srsenb

# srsRAN ZMQ eNB (RF simulated)
docker compose -f srsenb_zmq.yaml up -d && docker container attach srsenb_zmq

# srsRAN ZMQ 4G UE (RF simulated)
docker compose -f srsue_zmq.yaml up -d && docker container attach srsue_zmq

# 4G Core Network + IMS + SMS over SGs (uses Kamailio IMS) + Osmo-epdg + Strongswan-epdg
docker compose -f 4g-volte--vowifi-deploy.yaml up

# SWu-IKEv2 (ePDG testing)
docker compose -f swu_client.yaml up -d && docker container attach swu_client
```

###### 5G SA deployment

```
# 5G Core Network
docker compose -f sa-deploy.yaml up

# srsRAN gNB using SDR (OTA)
docker compose -f srsgnb.yaml up -d && docker container attach srsgnb

# srsRAN ZMQ gNB (RF simulated)
docker compose -f srsgnb_zmq.yaml up -d && docker container attach srsgnb_zmq

# srsRAN ZMQ 5G UE (RF simulated)
docker compose -f srsue_5g_zmq.yaml up -d && docker container attach srsue_5g_zmq

# UERANSIM gNB (RF simulated)
docker compose -f nr-gnb.yaml up -d && docker container attach nr_gnb

# UERANSIM NR-UE (RF simulated)
docker compose -f nr-ue.yaml up -d && docker container attach nr_ue
```

## Docker Compose files overview

This repository provides several Docker Compose files to support different deployment scenarios and components. Below is a summary of the compose files and their purposes:

| Compose File                       | Description                                                                                        |
|------------------------------------|----------------------------------------------------------------------------------------------------|
| `4g-volte-deploy.yaml`             | Deploys 4G Core Network (EPC) with IMS (VoLTE) using Kamailio.                                     |
| `4g-volte-opensips-ims-deploy.yaml`| Deploys 4G Core Network with IMS using OpenSIPS.                                                   |
| `sa-deploy.yaml`                   | Deploys 5G Standalone (SA) Core Network (5GC).                                                     |
| `sa-vonr-deploy.yaml`              | Deploys 5G Standalone (SA) Core Network (5GC) with IMS (VoNR) using Kamailio.                      |
| `srsenb.yaml`                      | Deploys srsRAN 4G eNB for OTA setups using SDR hardware.                                           |
| `srsenb_zmq.yaml`                  | Deploys srsRAN 4G eNB for RF simulated setups over ZMQ.                                            |
| `srsue_zmq.yaml`                   | Deploys srsRAN 4G UE for RF simulated setups over ZMQ.                                             |
| `srsran.yaml`                      | Deploys srsRAN_4G components (eNB/UE).                                                             |
| `srsgnb.yaml`                      | Deploys srsRAN 5G gNB for OTA setups using SDR hardware.                                           |
| `srsgnb_zmq.yaml`                  | Deploys srsRAN 5G gNB for RF simulated setups over ZMQ.                                            |
| `srsue_5g_zmq.yaml`                | Deploys srsRAN 5G UE for RF simulated setups over ZMQ.                                             |
| `nr-gnb.yaml`                      | Deploys UERANSIM 5G gNB simulator.                                                                 |
| `nr-ue.yaml`                       | Deploys UERANSIM 5G UE simulator.                                                                  |
| `4g-volte-ocs-deploy.yaml`         | Deploys 4G Core Network (EPC) + Sigscale OCS with IMS (VoLTE) using Kamailio.                      |
| `4g-external-ims-deploy.yaml`      | Deploys 4G Core Network (EPC) + Sigscale OCS + PyHSS (IMS) with no IMS components.                 |
| `4g-volte-vowifi-deploy.yaml`      | Deploys 4G Core Network (EPC) + Osmocom EPDG with IMS (VoLTE/VoWiFi) using Kamailio.               |
| `swu_client.yaml`                  | Deploys SWu-IKEv2 client for ePDG testing.                                                         |
| `sa-vonr-ibcf-deploy.yaml`         | Deploys 5G Standalone (SA) Core Network (5GC) + IMS (VoNR) using Kamailio + IBCF.                  |
| `sa-vonr-opensips-ims-deploy.yaml` | Deploys 5G Standalone (SA) Core Network (5GC) with IMS (VoNR) using OpenSIPS (Experimental).       |
| `oaienb.yaml`                      | Deploys OAI eNB for OTA setups using SDR hardware (Untested and Unmaintained).                     |
| `oaignb.yaml`                      | Deploys OAI 5G gNB for OTA setups using SDR hardware (Untested and Unmaintained).                  |

## Provisioning of SIM information

### Provisioning of SIM information in open5gs HSS as follows:

Open (http://<DOCKER_HOST_IP>:9999) in a web browser, where <DOCKER_HOST_IP> is the IP of the machine/VM running the open5gs containers. Login with following credentials
```
Username : admin
Password : 1423
```

Using Web UI, add a subscriber with following details:

```
IMSI : <SIM_IMSI> (e.g. 001010123456790)
MSISDN : <DESIRED_MSISDN> (e.g. 9076543210)
AMF : 8000
K : <SIM_K> (e.g. 8baf473f2f8fd09487cccbd7097c6862)
OPC : <SIM_OPC> (e.g. 8E27B6AF0E692E750F32667A3B14605D)

APN Configuration:
---------------------------------------------------------------------------------------------------------------------
| APN      | Type | QCI | ARP | Capability | Vulnerablility | MBR DL/UL(Kbps)     | GBR DL/UL(Kbps) | PGW IP        |
---------------------------------------------------------------------------------------------------------------------
| internet | IPv4 | 9   | 8   | Disabled   | Disabled       | unlimited/unlimited |                 |               |
|          |      | 1   | 2   | Enabled    | Enabled        | 128/128             | 128/128         |               |
|          |      | 2   | 4   | Enabled    | Enabled        | 128/128             | 128/128         |               |
---------------------------------------------------------------------------------------------------------------------
| ims      | IPv4 | 5   | 1   | Disabled   | Disabled       | 3850/1530           |                 |               |
|          |      | 1   | 2   | Enabled    | Enabled        | 128/128             | 128/128         |               |
|          |      | 2   | 4   | Enabled    | Enabled        | 128/128             | 128/128         |               |
---------------------------------------------------------------------------------------------------------------------
```

#### or using cli 

```
sudo docker exec -it hss misc/db/open5gs-dbctl add 001010123456790 8baf473f2f8fd09487cccbd7097c6862 8E27B6AF0E692E750F32667A3B14605D
```
**NOTE:** Adding via CLI does not add the desired APN configuration. You need to add the APN configuration via Web UI as mentioned above.

### Provisioning of IMSI and MSISDN with OsmoHLR as follows:

1. First, telnet to OsmoHLR from host machine using the following command:

```
$ telnet 172.22.0.32 4258

OsmoHLR> enable
OsmoHLR#
```

2. Then, register the subscriber information as in following example:

```
OsmoHLR# subscriber imsi 001010123456790 create
OsmoHLR# subscriber imsi 001010123456790 update msisdn 9076543210
```

**Replace IMSI and MSISDN as per your programmed SIM**


### Provisioning of SIM information in pyHSS is as follows:

1. Goto http://<DOCKER_HOST_IP>:8080/docs/
2. Select **apn** -> **Create new APN** -> Press on **Try it out**. Then, in payload section use the below JSON and then press **Execute**

```
{
  "apn": "internet",
  "apn_ambr_dl": 0,
  "apn_ambr_ul": 0
}
```

Take note of **apn_id** specified in **Response body** under **Server response** for **internet** APN

Repeat creation step for following payload

```
{
  "apn": "ims",
  "apn_ambr_dl": 0,
  "apn_ambr_ul": 0
}
```

Take note of **apn_id** specified in **Response body** under **Server response** for **ims** APN

**Execute this step of APN creation only once**

3. Next, select **auc** -> **Create new AUC** -> Press on **Try it out**. Then, in payload section use the below example JSON to fill in ki, opc and amf for your SIM and then press **Execute**

```
{
  "ki": "8baf473f2f8fd09487cccbd7097c6862",
  "opc": "8E27B6AF0E692E750F32667A3B14605D",
  "amf": "8000",
  "sqn": 0,
  "imsi": "001010123456790"
}
```

Take note of **auc_id** specified in **Response body** under **Server response**

**Replace imsi, ki, opc and amf as per your programmed SIM**

4. Next, select **subscriber** -> **Create new SUBSCRIBER** -> Press on **Try it out**. Then, in payload section use the below example JSON to fill in imsi, auc_id and apn_list for your SIM and then press **Execute**

```
{
  "imsi": "001010123456790",
  "enabled": true,
  "auc_id": 1,
  "default_apn": 1,
  "apn_list": "1,2",
  "msisdn": "9076543210",
  "ue_ambr_dl": 0,
  "ue_ambr_ul": 0
}
```

- **auc_id** is the ID of the **AUC** created in the previous steps
- **default_apn** is the ID of the **internet** APN created in the previous steps
- **apn_list** is the comma separated list of APN IDs allowed for the UE i.e. APN ID for **internet** and **ims** APN created in the previous steps

**Replace imsi and msisdn as per your programmed SIM**

5. Finally, select **ims_subscriber** -> **Create new IMS SUBSCRIBER** -> Press on **Try it out**. Then, in payload section use the below example JSON to fill in imsi, msisdn, msisdn_list, scscf_peer, scscf_realm and scscf for your SIM/deployment and then press **Execute**

```
{
    "imsi": "001010123456790",
    "msisdn": "9076543210",
    "sh_profile": "string",
    "scscf_peer": "scscf.ims.mnc001.mcc001.3gppnetwork.org",
    "msisdn_list": "[9076543210]",
    "ifc_path": "default_ifc.xml",
    "scscf": "sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060",
    "scscf_realm": "ims.mnc001.mcc001.3gppnetwork.org"
}
```

**Replace imsi, msisdn and msisdn_list as per your programmed SIM**

**Replace scscf_peer, scscf and scscf_realm as per your deployment**

### Provisioning of Diameter Peer + Subscriber information in Sigscale OCS as follows (Skip if OCS is not deployed):

1. Goto http://<DOCKER_HOST_IP>:8083
2. Login with following credentials
```
Username : admin
Password : admin
```
3. Configure SMF as Diameter Peer as mentioned here - https://sigscale.atlassian.net/wiki/spaces/SO/pages/3833890/How-To+with+OCS#Add-an-DIAMETER-client-(DRA%2FSGSN%2FPGW)

    **NOTE:** IP address must be equal to **SMF_IP** in **.env** file and the Protocol must be set to Diameter.

4. Subscriber information can be provisioned as mentioned here - https://sigscale.atlassian.net/wiki/spaces/SO/pages/3833890/How-To+with+OCS#Add-a-subscriber

    **NOTE:** The IMSI and the MSISDN must be equal to the one provisioned in open5gs HSS and/or pyHSS.

## Testing VoWiFi with COTS UE

#### Pre-requisites
  - Set DOCKER_HOST_IP to the IP of the host machine where docker_open5gs is deployed.

#### Deploy the required components
  Ensure you have the following services running:
  - 4G Core Network (EPC)
  - IMS (Kamailio or OpenSIPS)
  - Osmo-ePDG and Strongswan-ePDG

  Start the VoWiFi-enabled deployment using:
  ```
  docker compose -f 4g-volte-vowifi-deploy.yaml up
  ```

#### Provision SIM and IMS subscriber information
  - Add subscriber details in open5gs HSS or pyHSS as described in the provisioning sections above.
  - Ensure the IMSI, MSISDN, and authentication keys match those programmed on your SIM.

#### Manually configure DNS settings on your phone (WiFi connection)
  - On your phone, go to the WiFi settings and select the network you are connected to.
  - Edit the network settings and look for the DNS configuration option (may be under "Advanced" or "IP settings").
    - On Android devices, switch from DHCP to Static IP configuration to manually set DNS.
    - On iOS devices, you can directly set the DNS server.
  - Set the DNS server to point to DOCKER_HOST_IP.
  - Save the settings and reconnect to the WiFi network.

  **Tip:** Proper DNS resolution is required for the UE to locate and register with IMS and ePDG services.

#### UE configuration
  - On your UE (User Equipment), ensure VoWiFi (WiFi calling) is enabled.

## Not supported
- IPv6 usage in Docker
