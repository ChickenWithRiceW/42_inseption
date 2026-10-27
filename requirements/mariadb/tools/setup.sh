#!/bin/sh


# Sets passwd to values.
DB_PASS=$(cat /run/secrets/db_password)
ROOT_PASS=$(cat /run/secrets/db_root_password)



# Cleanup dir in cases of half finished attempt before.
# Why not 'rm -fr *' ?. It would not remove hidden files.
find /var/lib/mysql -mindepth 1 -delete

# Init DB
mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db


# Temporary server, not reachable over the network
mysqld --user=mysql --skip-networking &
pid=$!

# Bounded wait: gives up after 30 tries instead of looping forever
i=0
until mysqladmin ping --silent 2>/dev/null; do
    i=$((i + 1))
    if [ "$i" -ge 30 ]; then
        echo "[setup] server did not start" >&2
        exit 1
    fi
    sleep 1
done

# Root still has no password here, so no -p yet
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Root has a password now, so -p is required
mysqladmin -u root -p"${ROOT_PASS}" shutdown
wait "$pid"

# Last line on purpose: only exists if everything above succeeded
touch /var/lib/mysql/.setup_done
