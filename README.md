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

## Building docker images

* Mandatory requirements:
	* [docker-ce](https://docs.docker.com/install/linux/docker-ce/ubuntu) - Version 22.0.5 or above
	* [docker compose](https://docs.docker.com/compose) - Version 2.14 or above


#### Clone repository and build base docker image of open5gs, kamailio, srsRAN_4G, srsRAN_Project, ueransim

```
# Build docker images for open5gs EPC/5GC components
git clone https://github.com/herlesupreeth/docker_open5gs
cd docker_open5gs/base
docker build --no-cache --force-rm -t docker_open5gs .

# Build docker images for kamailio IMS components
cd ../ims_base
docker build --no-cache --force-rm -t docker_kamailio .

# Build docker images for srsRAN_4G eNB + srsUE (4G+5G)
cd ../srslte
docker build --no-cache --force-rm -t docker_srslte .

# Build docker images for srsRAN_Project gNB
cd ../srsran
docker build --no-cache --force-rm -t docker_srsran .

# Build docker images for UERANSIM (gNB + UE)
cd ../ueransim
docker build --no-cache --force-rm -t docker_ueransim .
```

#### Build docker images for additional components

```
cd ..
set -a
source .env
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
    external:
      name: docker_open5gs_default
```
with 
```
	network_mode: host
```

## Network Deployment

###### 4G deployment

```
# 4G Core Network + IMS + SMS over SGs
docker compose -f 4g-volte-deploy.yaml up

# srsRAN eNB using SDR (OTA)
docker compose -f srsenb.yaml up -d && docker container attach srsenb

# srsRAN ZMQ eNB (RF simulated)
docker compose -f srsenb_zmq.yaml up -d && docker container attach srsenb_zmq

# srsRAN ZMQ 4G UE (RF simulated)
docker compose -f srsue_zmq.yaml up -d && docker container attach srsue_zmq
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

## Provisioning of SIM information

### Provisioning of SIM information in open5gs HSS as follows:

Open (http://<DOCKER_HOST_IP>:9999) in a web browser, where <DOCKER_HOST_IP> is the IP of the machine/VM running the open5gs containers. Login with following credentials
```
Username : admin
Password : 1423
```

Using Web UI, add a subscriber

#### or using cli 

```
sudo docker exec -it hss misc/db/open5gs-dbctl add 001010123456790 8baf473f2f8fd09487cccbd7097c6862 8E27B6AF0E692E750F32667A3B14605D
```


### Provisioning of IMSI and MSISDN with OsmoHLR as follows:

1. First, login to the osmohlr container

```
docker exec -it osmohlr /bin/bash
```

2. Then, telnet to localhost

```
$ telnet localhost 4258

OsmoHLR> enable
OsmoHLR#
```

3. Finally, register the subscriber information as in following example:

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

## Not supported
- IPv6 usage in Docker
