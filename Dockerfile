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
        trickle

# 1. Create new unprivileged user "dev"
# 2. Install fixuid to accomodate for the host machine UID/GID
RUN useradd -m -s /bin/bash dev && \
    wget -nv -O - https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf -

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
