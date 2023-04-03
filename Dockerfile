FROM ubuntu:focal AS fetcher

ARG name=defaultValue

# Place the Enclave binary in a local 'extract' folder.
# The latest Enclave binaries for linux can be retrieved from our manifest: https://install.enclave.io/manifest/linux.json
COPY extract/ /tmp/extract
RUN cp /tmp/extract/$(dpkg --print-architecture)/enclave /tmp/enclave && rm -rd /tmp/extract

# Setup apt for noninteractive mode
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl gnupg2 jq ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


FROM ubuntu:focal

# Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    iproute2 \
    iptables \
    libc6 \
    libgcc1 \
    libgssapi-krb5-2 \
    libicu66 \
    libssl1.1 \
    libstdc++6 \
    openssl \
    zlib1g \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Helpers
# RUN apt-get install net-tools nano iputils-ping

RUN update-ca-certificates

WORKDIR /usr/bin
COPY --from=fetcher /tmp/enclave .
RUN chmod +x /usr/bin/enclave

ENTRYPOINT [ "enclave" ]
CMD [ "run" ]
