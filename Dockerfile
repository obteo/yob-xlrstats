FROM centos:7

RUN sed -i \
    -e 's|mirrorlist=|#mirrorlist=|g' \
    -e 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' \
    /etc/yum.repos.d/CentOS-Base.repo

RUN yum clean all && yum makecache fast

RUN yum -y update && yum -y install \
    epel-release \
    yum-utils \
    wget \
    curl \
    git \
    unzip \
    ca-certificates \
    openssl \
    tar \
    gzip \
    && yum clean all

# -------------------------
# NGINX (official repo)
# -------------------------
RUN cat <<EOF > /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=https://nginx.org/packages/centos/7/\$basearch/
gpgcheck=0
enabled=1
EOF

RUN yum -y install nginx && yum clean all

# -------------------------
# PHP 5.4 (CentOS 7 default)
# -------------------------
RUN yum -y install \
    php \
    php-fpm \
    php-cli \
    php-common \
    php-mysql \
    php-pdo \
    php-gd \
    php-mbstring \
    php-xml \
    php-curl \
    php-ldap \
    php-mcrypt \
    php-json \
    php-opcache || true \
    && yum clean all

# -------------------------
# Cloudflared (multi-arch)
# -------------------------
RUN ARCH=$(uname -m); \
    if [ "$ARCH" = "x86_64" ]; then \
        URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.rpm"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.rpm"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi; \
    curl -L $URL -o /tmp/cloudflared.rpm && \
    yum -y localinstall /tmp/cloudflared.rpm && \
    rm -f /tmp/cloudflared.rpm

# -------------------------
# Composer
# -------------------------
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# -------------------------
# ionCube (best-effort PHP 5.x compatible)
# -------------------------
RUN ARCH=$(uname -m); \
    if [ "$ARCH" = "x86_64" ]; then \
        IONCUBE_ARCH="x86-64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        IONCUBE_ARCH="aarch64"; \
    else \
        echo "ionCube skipped"; exit 0; \
    fi; \
    cd /tmp && \
    curl -L -o ioncube.tar.gz \
    "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_${IONCUBE_ARCH}.tar.gz" || exit 0; \
    tar xzf ioncube.tar.gz || exit 0; \
    PHP_EXT=$(find /usr/lib64/php/modules -type f 2>/dev/null | head -1); \
    if [ -d /usr/lib64/php/modules ]; then \
        cp ioncube/ioncube_loader_lin_5.4.so /usr/lib64/php/modules/ || true; \
        echo "zend_extension=/usr/lib64/php/modules/ioncube_loader_lin_5.4.so" > /etc/php.d/00-ioncube.ini || true; \
    fi; \
    rm -rf /tmp/ioncube*

# -------------------------
# User container
# -------------------------
RUN useradd -m -d /home/container -s /bin/bash container

ENV USER=container
ENV HOME=/home/container

WORKDIR /home/container

# -------------------------
# Entrypoint
# -------------------------
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

STOPSIGNAL SIGINT

CMD ["/entrypoint.sh"]
