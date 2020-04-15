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

cd ../kamailio_base
docker build --no-cache --force-rm -t open5gs_kamailio .
```

### Steps when using only docker-ce

(Removed, because there are a lot of containers to create.)


### Steps when using docker-compose

```
cd ..
docker-compose build --no-cache

# Copy DNS setting to containers
./copy-env.sh

# Start MySQL and MongoDB first, in order to initialize the databases
docker-compose up mongo mysql

# To start everything
docker-compose up

# To start Open5GS core network without IMS
docker-compose up dns mongo hss mme pcrf pgw sgw

# To start IMS only
docker-compose up mysql rtpengine fhoss pcscf icscf scscf

# To test whether DNS is properly running
./test-dns.sh

```

### Run srsENB in a separated container

Sometimes you may want to restart srsENB while keeping the core network running.  It is thus recommended to run srsENB separately.

With Docker-Compose:
```
docker-compose -f srsenb.yaml build --no-cache
docker-compose -f srsenb.yaml up
```

With Docker CE only or for debugging:
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
