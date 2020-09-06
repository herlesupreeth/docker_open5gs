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
docker-compose -f srsenb.yaml up
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
On the eNB, make sure to have the static route to SGW container (since internal IP of the SGW container is advertised in S1AP messages and UE wont find the core in Uplink)

```
ip r add <SGW_CONTAINER_IP> via <DOCKER_HOST_IP>
```

## Not supported
- IPv6 usage in Docker

## Appendix

### Steps when using only docker-ce

```
cd ..
set -a
source .env

# Create a Test Network
docker network create --subnet=${TEST_NETWORK} test_net

# MONGODB
cd mongo
docker build --no-cache --force-rm -t docker_open5gs_mongo .
docker volume create mongodbdata
docker run -dit -v "$(pwd)":/mnt/mongo -v mongodbdata:/var/lib/mongodb -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --expose=27017/udp --expose=27017/tcp --net test_net --ip ${MONGO_IP} --name mongo docker_open5gs_mongo

# HSS
cd ../hss
docker build --no-cache --force-rm -t docker_open5gs_hss .
docker run -dit -v "$(pwd)":/mnt/hss -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --env-file ../.env --expose=3868/udp --expose=3868/tcp --expose=3868/sctp --expose=5868/udp --expose=5868/tcp --expose=5868/sctp -p 3000:3000/tcp --net test_net --ip ${HSS_IP} --name hss docker_open5gs_hss

# PCRF
cd ../pcrf
docker build --no-cache --force-rm -t docker_open5gs_pcrf .
docker run -dit -v "$(pwd)":/mnt/pcrf -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --env-file ../.env --expose=3868/udp --expose=3868/tcp --expose=3868/sctp --expose=5868/udp --expose=5868/tcp --expose=5868/sctp --net test_net --ip ${PCRF_IP} --name pcrf docker_open5gs_pcrf

# SGW
cd ../sgw
docker build --no-cache --force-rm -t docker_open5gs_sgw .
docker run -dit -v "$(pwd)":/mnt/sgw -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --env-file ../.env --expose=2123/udp --expose=2152/udp -p 2152:2152/udp --net test_net --ip ${SGW_IP} --name sgw docker_open5gs_sgw

# PGW
cd ../pgw
docker build --no-cache --force-rm -t docker_open5gs_pgw .
docker run -dit -v "$(pwd)":/mnt/pgw -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --cap-add=NET_ADMIN --device /dev/net/tun --env-file ../.env --sysctl net.ipv4.ip_forward=1 --expose=3868/udp --expose=3868/tcp --expose=3868/sctp --expose=5868/udp --expose=5868/tcp --expose=5868/sctp --expose=2152/udp --expose=2123/udp --net test_net --ip ${PGW_IP} --name pgw docker_open5gs_pgw

# MME
cd ../mme
docker build --no-cache --force-rm -t docker_open5gs_mme .
docker run -dit -v "$(pwd)":/mnt/mme -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --env-file ../.env --expose=3868/udp --expose=3868/tcp --expose=3868/sctp --expose=5868/udp --expose=5868/tcp --expose=5868/sctp --expose=36412/sctp -p 36412:36412/sctp --net test_net --ip ${MME_IP} --name mme docker_open5gs_mme

# DNS
cd ../dns
docker build --no-cache --force-rm -t docker_dns .
docker run -dit -v "$(pwd)":/mnt/dns -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --env-file ../.env --expose=53/udp --net test_net --ip ${DNS_IP} --name dns docker_dns

# RTPENGINE
cd ../rtpengine
docker build --no-cache --force-rm -t docker_rtpengine .
docker run -dit --cap-add=NET_ADMIN --privileged --env-file ../.env -v "$(pwd)":/mnt/rtpengine -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro -e TABLE='0' -e INTERFACE=${RTPENGINE_IP} -e LISTEN_NG=${RTPENGINE_IP}:2223 -e PIDFILE='/run/ngcp-rtpengine-daemon.pid' -e PORT_MAX='50000' -e PORT_MIN='49000' -e NO_FALLBACK='yes' --expose=2223 -p 49000-50000:49000-50000/udp --net test_net --ip ${RTPENGINE_IP} --name rtpengine docker_rtpengine

# MYSQL
cd ../mysql
docker build --no-cache --force-rm -t docker_mysql .
docker volume create dbdata
docker run -dit -v dbdata:/var/lib/mysql -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --expose=3306/tcp --net test_net --ip ${MYSQL_IP} --name mysql docker_mysql

# FHOSS
cd ../fhoss
docker build --no-cache --force-rm -t docker_fhoss .
docker run -dit -v "$(pwd)":/mnt/fhoss -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --env-file ../.env --dns=${DNS_IP} --expose=3868/tcp --expose=3868/udp -p 8080:8080/tcp --net test_net --ip ${FHOSS_IP} --name fhoss docker_fhoss

# ICSCF
cd ../icscf
docker build --no-cache --force-rm -t docker_icscf .
docker run -dit -v "$(pwd)":/mnt/icscf -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --env-file ../.env --dns=${DNS_IP} --expose=3869/tcp --expose=3869/udp --expose=4060/udp --expose=4060/tcp --net test_net --ip ${ICSCF_IP} --name icscf docker_icscf

# SCSCF
cd ../scscf
docker build --no-cache --force-rm -t docker_scscf .
docker run -dit -v "$(pwd)":/mnt/scscf -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --env-file ../.env --dns=${DNS_IP} --expose=3870/tcp --expose=3870/udp --expose=6060/udp --expose=6060/tcp --net test_net --ip ${SCSCF_IP} --name scscf docker_scscf

# PCSCF
cd ../pcscf
docker build --no-cache --force-rm -t docker_pcscf .
docker run -dit -v "$(pwd)":/mnt/pcscf -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --cap-add=NET_ADMIN --privileged --env-file ../.env --dns=${DNS_IP} -p 5100-5120:5100-5120/tcp -p 5100-5120:5100-5120/udp -p 6100-6120:6100-6120/tcp -p 6100-6120:6100-6120/udp -p 3871:3871/tcp -p 3871:3871/udp -p 5060:5060/tcp -p 5060:5060/udp --net test_net --ip ${PCSCF_IP} --name pcscf docker_pcscf

# ENB
cd ../srslte
docker build --no-cache --force-rm -t docker_srslte .
docker run -dit -v "$(pwd)":/mnt/srslte -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --device /dev/bus -v /dev/bus/usb:/dev/bus/usb:ro -v /dev/serial:/dev/serial:ro --privileged --env-file ../.env --expose=36412/sctp --expose=2152/udp --net test_net --ip ${ENB_IP} --name srsenb docker_srslte
```
