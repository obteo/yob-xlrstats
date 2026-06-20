FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# -------------------------
# DEPENDENCIES (FIXED for PHP 5.6 compile)
# -------------------------
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    bison \
    re2c \
    pkg-config \
    wget \
    curl \
    git \
    unzip \
    tar \
    gzip \
    ca-certificates \
    libxml2-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libreadline-dev \
    libicu-dev \
    libzip-dev \
    libonig-dev \
    libsqlite3-dev \
    libxslt1-dev \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# WORKDIR
# -------------------------
RUN mkdir -p /home/container/tmp /home/container/www
WORKDIR /home/container

# -------------------------
# PHP VERSION
# -------------------------
ENV PHP_VERSION=5.6.40

# -------------------------
# BUILD PHP 5.6
# -------------------------
RUN cd /home/container/tmp && \
    wget https://museum.php.net/php5/php-${PHP_VERSION}.tar.gz && \
    tar -xzf php-${PHP_VERSION}.tar.gz && \
    cd php-${PHP_VERSION} && \
    export CFLAGS="-fcommon" && \
    export CPPFLAGS="-fcommon" && \
    ./configure \
        --prefix=/usr/local/php \
        --with-config-file-path=/usr/local/php/etc \
        --enable-fpm \
        --with-mysqli=mysqlnd \
        --with-pdo-mysql=mysqlnd \
        --with-mysql=mysqlnd \
        --with-curl \
        --with-openssl \
        --with-zlib \
        --enable-mbstring \
        --enable-xml \
        --enable-simplexml \
        --enable-dom \
        --enable-bcmath \
        --enable-soap \
        --enable-sockets \
        --enable-zip \
        --with-gd \
        --with-jpeg-dir=/usr \
        --with-png-dir=/usr \
        --with-xsl && \
    make -j$(nproc) && \
    make install

# -------------------------
# PHP CONFIG
# -------------------------
RUN mkdir -p /usr/local/php/etc && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf || true

# -------------------------
# CLEANUP
# -------------------------
RUN rm -rf /home/container/tmp
