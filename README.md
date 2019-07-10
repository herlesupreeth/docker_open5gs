# docker_nextepc
Docker files to build and run NextEPC in a docker

## Build Instructions

* Mandatory requirements:
	* docker-ce	- https://docs.docker.com/install/linux/docker-ce/ubuntu/


Download and build docker image of NextEPC: 
```
cd ~ && git clone https://github.com/herlesupreeth/docker_nextepc
cd nextepc
docker build --force-rm -t nextepc:v0.1 .
```

## Execution Instructions

```
cd ~/nextepc
docker run --rm -it --cap-add=NET_ADMIN --env-file=docker_env --name epc --net=host --device /dev/net/tun --sysctl net.ipv4.ip_forward=1 nextepc:v0.1
```

###### Notes:
- --net=host is required in order to allow binding of ports in the container
- The container requires NET_ADMIN permission in order to create a tun interface

## Configuration:

The following parameters can be modified in 'docker_env' file before running 'docker run' command to suit your Core Network deployment

* MCC - Mobile Country Code
* MNC - Mobile Network Code
* TAC1 - Tracking Area Code
* EPC_IF - Network Interface name to bind SGW and MME