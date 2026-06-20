FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# -------------------------
# fix repo (18.04 EOL safe mode)
# -------------------------
RUN sed -i 's|archive.ubuntu.com|old-releases.ubuntu.com|g' /etc/apt/sources.list && \
    sed -i 's|security.ubuntu.com|old-releases.ubuntu.com|g' /etc/apt/sources.list && \
    apt-get update

# -------------------------
# base tools for PHP 5.4 / 5.6 build
# -------------------------
RUN apt-get install -y \
    build-essential \
    autoconf \
    bison \
    re2c \
    libxml2-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng-dev \
    libzip-dev \
    libssl-dev \
    libreadline-dev \
    libicu-dev \
    libonig-dev \
    wget \
    curl \
    git \
    unzip \
    tar \
    gzip \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# working dirs (Pterodactyl safe)
# -------------------------
RUN mkdir -p /home/container/tmp /home/container/www

WORKDIR /home/container

CMD ["/bin/bash"]
