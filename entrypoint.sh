#!/bin/bash

echo "[START] Launching PHP 5.4 + Nginx stack"

# start php-fpm
/usr/local/php/sbin/php-fpm

# start nginx
nginx -g "daemon off;"
