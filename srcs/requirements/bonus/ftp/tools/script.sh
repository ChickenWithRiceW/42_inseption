#!/bin/sh
set -eu

mkdir -p /var/run/vsftpd/empty

# create user if it doesn't exist yet (idempotent across restarts)
id ftpuser >/dev/null 2>&1 || adduser --disabled-password --gecos "" ftpuser

echo "ftpuser:$(cat /run/secrets/ftp_user_password)" | chpasswd

exec "vsftpd"