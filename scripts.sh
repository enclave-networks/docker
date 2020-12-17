#!/bin/bash

# Build container (stable)
docker build -t enclavenetworks/enclave:latest .

# Build container (specific version)
docker build --build-args channel=unstable --build-args version=2020.12.16.513 -t enclavenetworks/enclave:unstable .

# Run container, mounting profile folder, starting with bash
docker run -it --entrypoint /bin/bash \
               --cap-add NET_ADMIN \
               --device /dev/net/tun \
               -v /home/alistair/enclave-profile:/etc/enclave/profiles \
               -t enclavenetworks/enclave:latest

# Start Enclave inside a container, in the background.

docker run -it --cap-add NET_ADMIN \
               --device /dev/net/tun \
               -v /home/alistair/enclave-profile:/etc/enclave/profiles \
               --name enclave2 \
               -d \
               -t enclavenetworks/enclave:latest start --interactive