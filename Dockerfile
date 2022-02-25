FROM ubuntu:20.04

# Install prerequisites for the "iop" script and iopsys-taas
RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -y install \
        locales \
        sudo \
        wget \
        expect \
        socat \
        curl \
        sshpass \
        trickle \
        python3-mako \
        python3-yaml

# Install Node.js
ARG NODEJS_VERSION_MAJOR=14
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODEJS_VERSION_MAJOR}.x" | bash - && \
    apt-get install -y nodejs && \
    npm install --global typescript yarn

# 1. Create new unprivileged user "dev"
# 2. Install fixuid to accomodate for the host machine UID/GID
ARG FIXUID_VERSION=0.5.1
RUN useradd -m -s /bin/bash dev && \
    curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz" | tar -C /usr/local/bin -xzf -

# Copy fixuid configuration
COPY docker/fixuid.yml /etc/fixuid/config.yml

# Copy git configuration to dev's home folder
COPY --chown=dev:dev docker/gitconfig /home/dev/.gitconfig

# Run "iop setup_host" inside image to install necessary SDK dependencies
COPY iop /

RUN echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections && \
    ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    yes | /iop setup_host && \
    rm /iop

RUN echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/10-dev

USER dev:dev
ENTRYPOINT ["/usr/local/bin/fixuid", "-q"]
CMD ["bash"]
RUN mkdir -p /home/dev/iopsyswrt /home/dev/.ssh
WORKDIR /home/dev/iopsyswrt
VOLUME ["/home/dev/iopsyswrt"]
