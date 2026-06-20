FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# -------------------------
# FORCE stable old-releases repo (clean override)
# -------------------------
RUN printf "deb http://old-releases.ubuntu.com/ubuntu bionic main restricted universe multiverse\n" > /etc/apt/sources.list && \
    printf "deb http://old-releases.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse\n" >> /etc/apt/sources.list && \
    printf "deb http://old-releases.ubuntu.com/ubuntu bionic-security main restricted universe multiverse\n" >> /etc/apt/sources.list

# -------------------------
# APT update fix for expired metadata
# -------------------------
RUN apt-get -o Acquire::Check-Valid-Until=false update || true

# -------------------------
# base packages for PHP 5.6 / 5.4 builds
# -------------------------
RUN apt-get install -y --allow-unauthenticated \
    build-essential \
    autoconf \
    bison \
    re2c \
    wget \
    curl \
    git \
    unzip \
    tar \
    gzip \
    libxml2-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libreadline-dev \
    libicu-dev \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# working dirs (Pterodactyl safe)
# -------------------------
RUN mkdir -p /home/container/tmp /home/container/www

WORKDIR /home/container

CMD ["/bin/bash"]
