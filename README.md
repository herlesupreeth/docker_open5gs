# docker_open5gs
Docker files to build and run open5gs in a docker

## Build and Execution Instructions

* Mandatory requirements:
	* [docker-ce](https://docs.docker.com/install/linux/docker-ce/ubuntu)
	* [docker-compose](https://docs.docker.com/compose)


Clone repository and build base docker image of open5gs

```
git clone https://github.com/herlesupreeth/docker_open5gs
cd docker_open5gs/base
docker build --no-cache --force-rm -t docker_open5gs .

cd ../srslte
docker build --no-cache --force-rm -t docker_srsenb .
```

### Steps when using only docker-ce

```
# Create EPC Network
docker network create --subnet=172.18.0.0/16 epc_net

# HSS
cd ../hss
docker build --no-cache --force-rm -t docker_nextepc_hss .
docker run -dit -v "$(pwd)":/mnt/hss -p 3000:3000 -e MME_IP='172.18.0.3' --net epc_net --ip 172.18.0.2 --name hss docker_nextepc_hss

# PCRF
cd ../pcrf
docker build --no-cache --force-rm -t docker_nextepc_pcrf .
docker run -dit -v "$(pwd)":/mnt/pcrf -e PGW_IP='172.18.0.5' -e HSS_IP='172.18.0.2' --net epc_net --ip 172.18.0.6 --name pcrf docker_nextepc_pcrf

# SGW
cd ../sgw
docker build --no-cache --force-rm -t docker_nextepc_sgw .
docker run -dit -v "$(pwd)":/mnt/sgw -p 2152:2152/udp --net epc_net --ip 172.18.0.4 --name sgw docker_nextepc_sgw

# PGW
cd ../pgw
docker build --no-cache --force-rm -t docker_nextepc_pgw .
docker run -dit -v "$(pwd)":/mnt/pgw --cap-add=NET_ADMIN --device /dev/net/tun -e PCRF_IP='172.18.0.6' --sysctl net.ipv4.ip_forward=1 --net epc_net --ip 172.18.0.5 --name pgw docker_nextepc_pgw

# MME
cd ../mme
docker build --no-cache --force-rm -t docker_nextepc_mme .
docker run -dit -v "$(pwd)":/mnt/mme -p 36412:36412/sctp -e HSS_IP='172.18.0.2' -e SGW_IP='172.18.0.4' -e PGW_IP='172.18.0.5' --net epc_net --ip 172.18.0.3 --name mme docker_nextepc_mme
```

### Steps when using docker-compose

```
cd ..
docker-compose build --no-cache
docker-compose up
```

### Run srsENB in a separated container

Sometimes you may want to restart srsENB while keeping the core network running.  It is thus recommended to run srsENB separately.

```
cd srsenb
cp ../.env .
docker run -it --rm --privileged -v "$(pwd)":/mnt/srsenb -v /dev/bus/usb:/dev/bus/usb --net docker_open5gs_default --ip 172.18.0.7 --name srsenb docker_srsenb
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

```
ip r add <SGW_CONTAINER_IP> via <DOCKER_HOST_IP>
```

## Not supported
- IPv6 usage in Docker
