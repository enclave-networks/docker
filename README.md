# hub.docker.com/r/enclavenetworks/enclave

[![Build Status](https://img.shields.io/docker/cloud/build/enclavenetworks/enclave.svg)](https://hub.docker.com/r/enclavenetworks/enclave)
[![Docker Pulls](https://img.shields.io/docker/pulls/enclavenetworks/enclave.svg)](https://hub.docker.com/r/enclavenetworks/enclave)
[![Docker Stars](https://img.shields.io/docker/stars/enclavenetworks/enclave.svg)](https://hub.docker.com/r/enclavenetworks/enclave)

<p>&nbsp;</p>

## Running Enclave with Docker Compose

1. Download our [docker-compose.yml](https://raw.githubusercontent.com/enclave-networks/container.enclave/main/docker-compose.yml) file.

```
$ wget https://raw.githubusercontent.com/enclave-networks/container.enclave/main/docker-compose.yml
```

2. Set the value of `ENCLAVE_ENROLMENT_KEY` in the `docker-compose.yml` file. Visit https://enclave.io to create an account. You can get an enrolment key from the [portal](https://portal.enclave.io) once you're signed in.

3. Bring the container up.

```
$ docker-compose up -d
```

4. Check the container is up. Make a note of your `Local identity`, you'll need to share this with other systems which you want to connect to.

```
$ docker exec fabric enclave status
```

5. Let's say you want to build a connect to another system running Enclave whose Identity is `3RWWG`. Use `docker exec` to authorise a connection to that system.

```
$ docker exec fabric enclave add 3RWWG
```

## Running Enclave Manually

#### 1. Create an Enclave account

Visit https://enclave.io to create an account. You'll need to get an enrolment key from the [portal](https://portal.enclave.io) once you're signed in.

#### 2. Create a persistent data store

Create a docker volume on the host to persist Enclave configuration data and container identity between restarts. 

```bash
$ docker volume create enclave-config
```

Enclave persists configuration, key material and container identity between restarts in the docker volume you create. If you need to run your Enclave container from another system, specify an explicit local path for `/etc/enclave/profiles` instead of a docker volume, and you can export the profile.

#### 3. Start the container with an Enrolment key

Run the container and set your Enrolment key as an environment variable using the `-e` flag (`$ENCLAVE_ENROLMENT_KEY`). Once Enclave is running you can detached from the container using the `Ctrl-p` then `Ctrl-q`, or use `-d` with `docker run` to start the container directly in detached mode.

```
$ docker run -it \
                  --name fabric \
                  --cap-add NET_ADMIN \
                  --device /dev/net/tun \
                  -e ENCLAVE_ENROLMENT_KEY='XXXXX-XXXXX-XXXXX-XXXXX-XXXXX' \
                  -v enclave-config:/etc/enclave/profiles \
                  -t enclavenetworks/enclave:latest
```

Enrolment keys can also be injected into the container as command line arguments, `start --enrolment-key XXXXX-XXXXX-XXXXX-XXXXX-XXXXX`.

**Note**: Running Enclave inside a docker container requires more than just basic privileges. Specifically, you
must provide the `--cap-add NET_ADMIN` and `--device /dev/net/tun` options for Enclave to create a tap device inside the container.

If your container stops, restart it using `docker restart fabric`.

#### 4. Run commands against enclave from outside the container with `docker exec`.

```
$ docker exec fabric enclave status

Local identity: R899Q

   Release version . . : 2021.1.1.532
   Profile name. . . . : Universe
   Profile location. . : /etc/enclave/profiles/Universe.profile
   Certificate . . . . : CN=R899Q Expires=Never (Perpetual Issue)
   Binding address . . : 0.0.0.0:37873
   Local nameserver. . : listening on 100.110.213.200:53
   Virtual adapter . . : tap0 (#2) BE:18:63:A5:3A:2D
   Virtual address . . : 100.110.213.200
   Virtual network . . : 100.64.0.0/10 (255.192.0.0)
   Capabilities. . . . : enclave\fakearp   active pri=4096 local rewrites=0 peer discards=0
                       : enclave\unicast   active pri=8192 tap eth=0 ipv4=0 ipv6=0 - partners total=0 spoofed origin discards=0
                       : enclave\multicast active pri=8200 igmp membership packets ipv4=0 ipv6=0

Peer: discover.enclave.io

   Peer state. . . . . : Up
   Certificate . . . . : CN=discover.enclave.io Expires=08/06/2024 09:59:59
   Endpoint. . . . . . : Tcp/161.35.171.235:443
```

Authorise connections to the systems you need to reach (and make sure those systems have authorised your Local Identity in return).

```
$ docker exec fabric enclave add 8H62G -d "teamcity"
$ docker exec fabric enclave add Q8V28 -d "raspberry pi"
$ docker exec fabric enclave add 7L5GY -d "sarah laptop"
$ docker exec fabric enclave add 4Y66W -d "mongodb-nyc-1"
$ docker exec fabric enclave add Y7339 -d "mongodb-nyc-2"
$ docker exec fabric enclave add 968G2 -d "mongodb-lon-3"
```

 Add your configured **Virtual address** (in this example `100.110.213.200`) as a DNS server to your docker container to be able to resolve system names. Print the contents of /etc/resolv.conf to verify the change and install the `ping` utility to verify peers are accessible by hostname.
 
 ```
$ docker exec fabric cat /etc/resolv.conf
nameserver 100.82.99.37
nameserver 8.8.8.8
$ docker exec fabric apt-get update && apt-get install -t iputils-ping 
$ docker exec fabric ping teamcity.enclave
PING teamcity.enclave (100.73.136.78) 56(84) bytes of data.
64 bytes from 100.73.136.78 (100.73.136.78): icmp_seq=1 ttl=128 time=17.4 ms
64 bytes from 100.73.136.78 (100.73.136.78): icmp_seq=2 ttl=128 time=13.9 ms
```

## Configure other containers to share the Enclave network

You can also configure other containers to share the IP stack of your Enclave container using the `--network` docker argument. By running new, or existing containers which share the IP stack of an enclave container, you can quickly and easilly expose those containers to other infrastructure connected to your Enclave container, without needing to map ports or change network configuration:

```bash
$ sudo docker run --name my-nginx \
             --network="container:fabric" 
             -d nginx
```

## Create a "dirty" working container

Create a "dirty" working container which shares the same network stack as your enclave container and access connected hosts.

```
docker run -it --rm --network="container:fabric" ubuntu:20.04
root@74f19fa990b1:/# apt-get update && apt-get install -y net-tools nano iputils-ping
root@74f19fa990b1:/# ping teamcity.enclave
PING teamcity.enclave (100.73.136.78) 56(84) bytes of data.
64 bytes from 100.73.136.78 (100.73.136.78): icmp_seq=1 ttl=128 time=17.4 ms
64 bytes from 100.73.136.78 (100.73.136.78): icmp_seq=2 ttl=128 time=13.9 ms
```

