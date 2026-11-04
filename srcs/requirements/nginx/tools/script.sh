#!/bin/sh

set -eu

CERT_DIR=/etc/nginx/ssl
if [ ! -f "$CERT_DIR/server.crt" ]; then
    mkdir -p "$CERT_DIR"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$CERT_DIR/server.key" \
        -out "$CERT_DIR/server.crt" \
        -subj "/CN=${DOMAIN_NAME}"
fi

exec nginx -g "daemon off;"
