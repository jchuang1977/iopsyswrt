FROM ubuntu:18.04

# Install prerequisites for the "iop" script
RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -y install \
        locales \
        sudo \
        wget

# 1. Create new unprivileged user "dev"
# 2. Install fixuid to accomodate for the host machine UID/GID
RUN useradd -m -s /bin/bash dev && \
    wget -O - https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf -

# Copy fixuid configuration
COPY docker/fixuid.yml /etc/fixuid/config.yml

# Copy git configuration to dev's home folder
COPY --chown=dev:dev docker/gitconfig /home/dev/.gitconfig

# Run "iop setup_host" inside image to install necessary SDK dependencies
COPY iop /

RUN yes | /iop setup_host && \
    rm /iop


USER dev:dev
ENTRYPOINT ["/usr/local/bin/fixuid", "-q"]
CMD ["bash"]
WORKDIR /home/dev/iopsyswrt
VOLUME ["/home/dev/iopsyswrt", "/home/dev/.ssh"]
