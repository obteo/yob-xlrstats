FROM debian:buster-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_VERSION=5.4.45
ENV TMPDIR=/home/container/tmp

# -------------------------
# Fix repo + install deps
# -------------------------
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list || true && \
    sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list || true && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated \
        build-essential \
        autoconf \
        bison \
        re2c \
        wget \
        curl \
        git \
        unzip \
        ca-certificates \
        libxml2-dev \
        libcurl4-openssl-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libssl-dev \
        libreadline-dev \
        libicu-dev \
        nginx \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# PHP build dir
# -------------------------
RUN mkdir -p /home/container/tmp

# -------------------------
# Build PHP 5.4
# -------------------------
RUN cd /home/container/tmp && \
    wget https://museum.php.net/php5/php-${PHP_VERSION}.tar.gz && \
    tar -xzf php-${PHP_VERSION}.tar.gz && \
    cd php-${PHP_VERSION} && \
    ./configure \
        --prefix=/usr/local/php \
        --with-config-file-path=/usr/local/php/etc \
        --enable-fpm \
        --with-mysql=mysqlnd \
        --with-mysqli=mysqlnd \
        --with-pdo-mysql=mysqlnd \
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
        --enable-zip && \
    make -j$(nproc) && \
    make install

# -------------------------
# PHP config
# -------------------------
RUN mkdir -p /usr/local/php/etc && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf || true

# -------------------------
# Pterodactyl safe dirs
# -------------------------
RUN mkdir -p /home/container/www /home/container/tmp

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /home/container

CMD ["/entrypoint.sh"]
