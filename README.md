<p>
    <a href="https://enclave.io/"><img src="https://portal.enclave.io/images/enclave.png"/></a>
</p>

Official docker container containing the Enclave client.

Check out https://enclave.io to start using Enclave to create secure networks.

# How to use this image

First, create a volume on the host to hold your enclave identity between restarts.

```bash
docker volume create enclave-id
```

Second, license the container with an Enrolment key. Enclave persists key material and profile data between container restarts in the volume you create. You will need an  enrolment key from your Enclave account https://portal.enclave.io.

```
$ docker run -it \
        -v enclave-id:/etc/enclave/profiles \
        -t enclavenetworks/enclave:latest \
        license
```

If you want to run the docker container in a different place to where you enrol it, specify an explicit local path rather than a docker volume, and you can export the profile.

Next, run enclave as a daemon:

**Note**: Running Enclave inside a docker container requires more than just basic privileges. Specifically, you
must provide the `--cap-add NET_ADMIN` and `--device /dev/net/tun` options for Enclave to create the tunnel.

```
$ docker run -it \
           --cap-add NET_ADMIN \
           --device /dev/net/tun \
           -v enclave-id:/etc/enclave/profiles \
           --name enclave-container \
           -d \
           -t enclavenetworks/enclave:latest \
           start --interactive
```

You can now run commands against enclave from outside the container with `exec`:
```
$ docker exec enclave-container enclave status

Local identity: 7L5LY

   Release version . . : 2020.12.14.507
   Profile name. . . . : Universe
   Profile location. . : /etc/enclave/profiles/Universe.profile
   Certificate . . . . : CN=7L5LY Expires=Never (Perpetual Issue)
   Binding address . . : 0.0.0.0:38139
   Local nameserver. . : listening on 100.108.103.231:53
   Virtual adapter . . : tap0 (#2) 42:54:60:26:89:EE
   Virtual address . . : 100.108.103.231
   Virtual network . . : 100.64.0.0/10 (255.192.0.0)
   Capabilities. . . . : enclave\fakearp   active pri=4096 local rewrites=2 peer discards=0
                       : enclave\unicast   active pri=8192 tap eth=51 ipv4=51 ipv6=0 - partners total=766 spoofed origin discards=0
                       : enclave\multicast active pri=8200 igmp membership packets ipv4=0 ipv6=0

Peer: discover.enclave.io

   Peer state. . . . . : Up
   Certificate . . . . : CN=discover.enclave.io Expires=08/06/2024 09:59:59
   Endpoint. . . . . . : Tcp/161.35.171.235:443

```

You can also configure other containers to share the IP stack of your Enclave container using the `--network` docker argument. By running new, or existing containers which share the IP stack of an enclave container, you can quickly and easilly expose those containers to other infrastructure connected to your Enclave container, without needing to map ports or change network configuration:

```bash
$ docker run --name my-nginx \
             --network="container:enclave-container" 
             -d nginx
```
