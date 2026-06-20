#!/bin/bash

echo "[START] XLRstats PHP 5.4 stack"

mkdir -p /home/container/tmp /home/container/www

export TMPDIR=/home/container/tmp

# -------------------------
# find php-fpm safely
# -------------------------
PHPFPM=$(find /usr/local -type f -name "php-fpm" 2>/dev/null | head -n 1)

if [ -z "$PHPFPM" ]; then
  echo "[ERROR] php-fpm not found. Build failed."
  exit 1
fi

echo "[INFO] Using PHP-FPM: $PHPFPM"

# start php-fpm
$PHPFPM -D

# start nginx
nginx -g "daemon off;"
