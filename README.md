# docker_open5gs
Docker files to build and run open5gs in a docker

## Build and Execution Instructions

* Mandatory requirements:
	* [docker-ce](https://docs.docker.com/install/linux/docker-ce)
	* [docker-compose](https://docs.docker.com/compose)

Clone repository and build docker image of open5gs:
```
cd ~ && git clone https://github.com/herlesupreeth/docker_open5gs

# Compile open5gs base image
cd docker_open5gs/base
docker build --force-rm -t open5gs:v0.1 .

# Create EPC Network
docker network create --subnet=172.18.0.0/16 epc_net

# HSS
cd ../hss
docker build --force-rm -t hss:v0.1 .
docker run -dit -v "$(pwd)":/mnt/hss -p 3000:3000 -e MME_IP='172.18.0.3' --net epc_net --ip 172.18.0.2 --name hss hss:v0.1

# PCRF
cd ../pcrf
docker build --force-rm -t pcrf:v0.1 .
docker run -dit -v "$(pwd)":/mnt/pcrf -e PGW_IP='172.18.0.5' -e HSS_IP='172.18.0.2' --net epc_net --ip 172.18.0.6 --name pcrf pcrf:v0.1

# SGW
cd ../sgw
docker build --force-rm -t sgw:v0.1 .
docker run -dit -v "$(pwd)":/mnt/sgw -p 2152:2152/udp --net epc_net --ip 172.18.0.4 --name sgw sgw:v0.1

# PGW
cd ../pgw
docker build --force-rm -t pgw:v0.1 .
docker run -dit -v "$(pwd)":/mnt/pgw --cap-add=NET_ADMIN --device /dev/net/tun -e PCRF_IP='172.18.0.6' --sysctl net.ipv4.ip_forward=1 --net epc_net --ip 172.18.0.5 --name pgw pgw:v0.1

# MME
cd ../mme
docker build --force-rm -t mme:v0.1 .
docker run -dit -v "$(pwd)":/mnt/mme -p 36412:36412/sctp -e HSS_IP='172.18.0.2' -e SGW_IP='172.18.0.4' -e PGW_IP='172.18.0.5' --net epc_net --ip 172.18.0.3 --name mme mme:v0.1
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

On the eNB, make sure to have the static route to SGW container (since internal IP of the SGW container is advertised in S1AP messages and UE wont find the core in Uplink)

$ ip r add <SGW_CONTAINER_IP> via <DOCKER_HOST_IP>

## Not supported
- IPv6 usage in Docker