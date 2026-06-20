FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# -------------------------
# FORCE stable repos (no sed, no guess)
# -------------------------
RUN printf "deb http://old-releases.ubuntu.com/ubuntu bionic main restricted universe multiverse\n" > /etc/apt/sources.list && \
    printf "deb http://old-releases.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse\n" >> /etc/apt/sources.list && \
    printf "deb http://old-releases.ubuntu.com/ubuntu bionic-security main restricted universe multiverse\n" >> /etc/apt/sources.list

# -------------------------
# FIX APT metadata (CRUCIAL)
# -------------------------
RUN apt-get clean && \
    apt-get -o Acquire::Check-Valid-Until=false update || true

# -------------------------
# install step SPLITTED (IMPORTANT for buildx stability)
# -------------------------
RUN apt-get install -y --allow-unauthenticated \
    ca-certificates \
    curl \
    wget \
    git \
    unzip \
    tar \
    gzip

RUN apt-get install -y --allow-unauthenticated \
    build-essential \
    autoconf \
    bison \
    re2c

RUN apt-get install -y --allow-unauthenticated \
    libxml2-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libreadline-dev \
    libicu-dev

RUN apt-get install -y --allow-unauthenticated nginx && \
    rm -rf /var/lib/apt/lists/*

# -------------------------
# working dirs (Pterodactyl safe)
# -------------------------
RUN mkdir -p /home/container/tmp /home/container/www

WORKDIR /home/container

CMD ["/bin/bash"]
