FROM debian:bookworm-slim

LABEL author="Ym0t" maintainer="YmoT@tuta.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_VERSION=5.4.45
ENV TMPDIR=/home/container/tmp

# -------------------------
# Base deps
# -------------------------
RUN apt-get update && apt-get install -y \
    build-essential autoconf bison re2c \
    libxml2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev \
    libzip-dev libssl-dev libreadline-dev libicu-dev \
    wget curl git unzip ca-certificates nginx \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# Build PHP 5.4
# -------------------------
RUN mkdir -p /home/container/tmp

RUN cd /home/container/tmp && \
    wget https://museum.php.net/php5/php-${PHP_VERSION}.tar.gz && \
    tar -xzf php-${PHP_VERSION}.tar.gz && \
    cd php-${PHP_VERSION} && \
    ./configure \
      --prefix=/usr/local/php \
      --with-config-file-path=/usr/local/php/etc \
      --enable-fpm \
      --with-mysql \
      --with-mysqli \
      --with-pdo-mysql \
      --with-curl \
      --with-openssl \
      --with-zlib \
      --enable-mbstring \
      --enable-zip \
      --enable-bcmath \
    && make -j$(nproc) \
    && make install

RUN mkdir -p /usr/local/php/etc && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf || true

# -------------------------
# nginx fix dirs (Pterodactyl safe)
# -------------------------
RUN mkdir -p /home/container/www /home/container/tmp

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /home/container

CMD ["/entrypoint.sh"]
