FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_VERSION=5.6.40

RUN apt-get update && apt-get install -y \
    build-essential autoconf bison re2c pkg-config \
    wget curl git unzip tar gzip ca-certificates \
    libxml2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev \
    libssl-dev libreadline-dev libicu-dev libzip-dev libonig-dev \
    libsqlite3-dev libxslt1-dev make \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/container/tmp /home/container/www

WORKDIR /home/container/tmp

RUN wget https://museum.php.net/php5/php-${PHP_VERSION}.tar.gz && \
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
        --with-xsl \
        --with-readline && \
    make -j1 && \
    make install

RUN mkdir -p /usr/local/php/etc

RUN rm -rf /home/container/tmp

WORKDIR /home/container

CMD ["/bin/bash"]
