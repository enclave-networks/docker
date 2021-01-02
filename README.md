# hub.docker.com/r/enclavenetworks/enclave

[![Build Status](https://img.shields.io/docker/cloud/build/enclavenetworks/enclave.svg)](https://hub.docker.com/r/enclavenetworks/enclave)
[![Docker Pulls](https://img.shields.io/docker/pulls/enclavenetworks/enclave.svg)](https://hub.docker.com/r/enclavenetworks/enclave)
[![Docker Stars](https://img.shields.io/docker/stars/enclavenetworks/enclave.svg)](https://hub.docker.com/r/enclavenetworks/enclave)

<p>&nbsp;</p>

## Docker container for Enclave

Check out https://enclave.io to start using Enclave to create secure networks.

## Test Enclave

Test that you can obtain and run the Enclave docker container by creating a container to print the Enclave version number. The `--rm` flag instructs Docker to automatically clean up the container and remove the file system when the container exits flag.

```
$ sudo docker run --rm -t enclavenetworks/enclave:latest version
```

## How to use this image

### 1. Create an Enclave account

Visit https://enclave.io to create an account. You'll need to get an enrolment key from the [portal](https://portal.enclave.io) once you're signed in.

### 2. Create a persistent data store

Create a docker volume on the host to persist Enclave configuration data and container identity between restarts. 

```bash
$ sudo docker volume create enclave-config
```

Enclave persists configuration, key material and container identity between restarts in the docker volume you create. If you need to run your Enclave container from another system, specify an explicit local path for `/etc/enclave/profiles` instead of a docker volume, and you can export the profile.

### 3. Start the container with an Enrolment key

Start the container using the `start` verb and passing an `--enrolment-key` command line argument in detached mode (`-d`).

```
$ sudo docker run -it \
                  --name enclave-container \
                  --cap-add NET_ADMIN \
                  --device /dev/net/tun \
                  -d \
                  -v enclave-config:/etc/enclave/profiles \
                  -t enclavenetworks/enclave:latest \
                  start --enrolment-key XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
```

Enrolment keys can also be injected into the container as environment variables using `-e ENCLAVE_ENROLMENT_KEY='XXXXX-XXXXX-XXXXX-XXXXX-XXXXX'`.

**Note**: Running Enclave inside a docker container requires more than just basic privileges. Specifically, you
must provide the `--cap-add NET_ADMIN` and `--device /dev/net/tun` options for Enclave to create a tap device inside the container.

### 3. Run commands against enclave from outside the container with `docker exec`.

```
$ sudo docker exec enclave-container enclave status

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

## Configure other containers to use the Enclave network

You can also configure other containers to share the IP stack of your Enclave container using the `--network` docker argument. By running new, or existing containers which share the IP stack of an enclave container, you can quickly and easilly expose those containers to other infrastructure connected to your Enclave container, without needing to map ports or change network configuration:

```bash
$ sudo docker run --name my-nginx \
             --network="container:enclave-container" 
             -d nginx
```
