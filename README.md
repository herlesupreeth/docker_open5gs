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
```

### Steps when using only docker-ce

```
cd ..
set -a
source .env

# Create a Test Network
docker network create --subnet=${TEST_NETWORK} test_net

# MONGODB
cd ../mongo
docker build --no-cache --force-rm -t docker_open5gs_mongo .
docker run -dit -v "$(pwd)":/mnt/mongo -v ../mongodb:/var/lib/mongodb --expose=27017/udp --expose=27017/tcp --net test_net --ip ${MONGO_IP} --name mongo docker_open5gs_mongo

# HSS
cd ../hss
docker build --no-cache --force-rm -t docker_open5gs_hss .
docker run -dit -v "$(pwd)":/mnt/hss --env-file ../.env --expose=3868/udp --expose=3868/tcp --expose=3868/sctp --expose=5868/udp --expose=5868/tcp --expose=5868/sctp -p 3000:3000/tcp --net test_net --ip ${HSS_IP} --name hss docker_open5gs_hss

# PCRF
cd ../pcrf
docker build --no-cache --force-rm -t docker_open5gs_pcrf .
docker run -dit -v "$(pwd)":/mnt/pcrf --env-file ../.env --expose=3868/udp --expose=3868/tcp --expose=3868/sctp --expose=5868/udp --expose=5868/tcp --expose=5868/sctp --net test_net --ip ${PCRF_IP} --name pcrf docker_open5gs_pcrf

# SGW
cd ../sgw
docker build --no-cache --force-rm -t docker_open5gs_sgw .
docker run -dit -v "$(pwd)":/mnt/sgw --env-file ../.env --expose=2123/udp -p 2152:2152/udp --net test_net --ip ${SGW_IP} --name sgw docker_open5gs_sgw

# PGW
cd ../pgw
docker build --no-cache --force-rm -t docker_open5gs_pgw .
docker run -dit -v "$(pwd)":/mnt/pgw --cap-add=NET_ADMIN --device /dev/net/tun --env-file ../.env --sysctl net.ipv4.ip_forward=1 --expose=3868/udp --expose=3868/tcp --expose=3868/sctp --expose=5868/udp --expose=5868/tcp --expose=5868/sctp --expose=2152/udp --expose=2123/udp --net test_net --ip ${PGW_IP} --name pgw docker_open5gs_pgw

# MME
cd ../mme
docker build --no-cache --force-rm -t docker_open5gs_mme .
docker run -dit -v "$(pwd)":/mnt/mme --env-file ../.env --expose=3868/udp --expose=3868/tcp --expose=3868/sctp --expose=5868/udp --expose=5868/tcp --expose=5868/sctp -p 36412:36412/sctp --net test_net --ip ${MME_IP} --name mme docker_open5gs_mme
```

### Steps when using docker-compose

```
cd ..
set -a
source .env
docker-compose build --no-cache
docker-compose up
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
