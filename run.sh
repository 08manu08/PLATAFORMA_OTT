#!/bin/sh

NGINX_CONFIG_FILE=/usr/local/nginx/conf/nginx.conf

echo "Starting server"
/usr/local/nginx/sbin/nginx -g "daemon off;"
