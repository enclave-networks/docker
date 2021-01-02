FROM ubuntu:focal AS fetcher

ARG channel=stable
ARG version

# Setup apt for noninteractive mode
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y curl gnupg2 \
 && export COMPUTED_ENCLAVE_VERSION=$(curl -fsSL https://install.enclave.io/latest/version) \
 && export ENCLAVE_VERSION=${version:-$COMPUTED_ENCLAVE_VERSION} \
 && cd /tmp \
 && curl -fsSL https://release.enclave.io/enclave_linux-x64-${channel}-${ENCLAVE_VERSION}.tar.gz | tar xz

FROM ubuntu:focal

# Dependencies
RUN apt-get update && apt-get install -y \
    libicu66 \
    libssl1.1 \
    zlib1g \
    libc6 \
    openssl \
    ca-certificates \
    iproute2

# Helpers
# RUN apt-get install net-tools nano iputils-ping

RUN update-ca-certificates

WORKDIR /usr/bin
COPY --from=fetcher /tmp/enclave .
RUN chmod +x /usr/bin/enclave

ENTRYPOINT [ "enclave" ]

CMD [ "start", "--interactive" ]
