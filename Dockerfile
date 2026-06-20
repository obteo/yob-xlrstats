FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_VERSION=5.6.40

RUN apt-get update && apt-get install -y \
    build-essential autoconf bison re2c pkg-config \
    wget curl git unzip tar gzip ca-certificates \
    nginx \
    libxml2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev \
    libssl-dev libreadline-dev libicu-dev libzip-dev libonig-dev \
    libsqlite3-dev libxslt1-dev make \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/container/tmp /home/container/www /var/lib/nginx/body /run/nginx

WORKDIR /home/container

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
        --enable-mysqlnd \
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
        --enable-zip \
        --with-gd \
        --with-jpeg-dir=/usr \
        --with-png-dir=/usr \
        --with-xsl \
        --with-readline && \
    make -j1 && \
    make install

RUN mkdir -p /usr/local/php/etc && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf || true && \
    cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf || true

RUN rm -rf /home/container/tmp

CMD ["/bin/bash"]
