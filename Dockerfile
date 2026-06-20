FROM debian:bookworm-slim

LABEL author="obteo" maintainer="obteo@live.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_VERSION=5.4.45

# -----------------------------
# Base deps + build tools
# -----------------------------
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    bison \
    re2c \
    libxml2-dev \
    libsqlite3-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libssl-dev \
    libreadline-dev \
    libicu-dev \
    libxslt1-dev \
    libmcrypt-dev \
    wget \
    curl \
    git \
    unzip \
    ca-certificates \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Compile PHP 5.4
# -----------------------------
RUN cd /tmp && \
    wget https://museum.php.net/php5/php-${PHP_VERSION}.tar.gz && \
    tar -xzf php-${PHP_VERSION}.tar.gz && \
    cd php-${PHP_VERSION} && \
    ./configure \
        --prefix=/usr/local/php \
        --with-config-file-path=/usr/local/php/etc \
        --enable-fpm \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
        --with-mysql \
        --with-mysqli \
        --with-pdo-mysql \
        --with-curl \
        --with-openssl \
        --with-zlib \
        --with-gd \
        --with-jpeg-dir \
        --with-png-dir \
        --enable-mbstring \
        --enable-zip \
        --enable-soap \
        --enable-sockets \
        --enable-exif \
        --enable-ftp \
        --enable-bcmath \
        && make -j$(nproc) && make install && \
    cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm || true && \
    rm -rf /tmp/php-${PHP_VERSION}*

# -----------------------------
# Config PHP
# -----------------------------
RUN mkdir -p /usr/local/php/etc && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf || true

# -----------------------------
# Nginx config (basic)
# -----------------------------
RUN mkdir -p /etc/nginx/conf.d

COPY nginx.conf /etc/nginx/conf.d/default.conf

# -----------------------------
# User + workspace
# -----------------------------
RUN useradd -m -d /home/container container

WORKDIR /home/container

# -----------------------------
# Entrypoint
# -----------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

STOPSIGNAL SIGTERM

CMD ["/entrypoint.sh"]
