# docker_open5gs
Docker files to build and run open5gs in a docker

## Tested Setup

Docker host machine

- Ubuntu 18.04 and 20.04

SDRs tested with srsLTE eNB

- Ettus USRP B210
- LimeSDR Mini v1.3

## Build and Execution Instructions

* Mandatory requirements:
	* [docker-ce](https://docs.docker.com/install/linux/docker-ce/ubuntu)
	* [docker-compose](https://docs.docker.com/compose)


Clone repository and build base docker image of open5gs

```
git clone https://github.com/herlesupreeth/docker_open5gs
cd docker_open5gs/base
docker build --no-cache --force-rm -t docker_open5gs .

cd ../ims_base
docker build --no-cache --force-rm -t docker_kamailio .
```

### Build and Run using docker-compose

```
cd ..
set -a
source .env
docker-compose build --no-cache
docker-compose up


docker-compose -f srsenb.yaml build --no-cache
docker-compose -f srsenb.yaml up -d && docker attach srsenb


docker-compose -f ueransim.yaml build --no-cache
docker-compose -f ueransim.yaml up -d && docker attach ueransim
```

## Configuration

The configuration files for each of the Core Network component can be found under their respective folder. Edit the .yaml files of the components before deploying each of the container

## Register a UE information

Open (http://<DOCKER_HOST_IP>:3000) in a web browser, where <DOCKER_HOST_IP> is the IP of the machine/VM running the open5gs containers. Login with following credentials
```
Username : admin
Password : 1423
```

Using Web UI, add a subscriber

## eNB settings

If DOCKER_HOST_IP is properly set to the host running the SGW container, then the following static route is not required.
On the eNB, make sure to have the static route to SGWU container (since internal IP of the SGWU container is advertised in S1AP messages and UE wont find the core in Uplink)

```
ip r add <SGWU_CONTAINER_IP> via <DOCKER_HOST_IP>
```

## Not supported
- IPv6 usage in Docker

