#!/bin/sh

set -eu

# Cleanup dir in cases of half finished attempt before.
# Why not 'rm -fr *' ?. It would not remove hidden files.
find /var/www/html -mindepth 1 -delete

chown www-data:www-data /var/www/html

# Download wordpress files.
runuser -u www-data -- wp core download --locale=en_GB --path="/var/www/html"

# Setup wordpress config file.
runuser -u www-data -- wp config create --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbhost="mariadb" --locale="en_GB" --path="/var/www/html" --prompt=dbpass < /run/secrets/db_password

# Create wordpress database table in mariadb.
runuser -u www-data -- wp core install --url="$DOMAIN_NAME" --title="$WP_TITEL" --admin_user="$WP_ADMIN" --admin_email="$WP_ADMIN_EMAIL" --skip-email --locale="en_GB" --path="/var/www/html" --prompt=admin_password < /run/secrets/wp_admin_password

# Create second user.
runuser -u www-data -- wp user create "$WP_USER" "$WP_USER_EMAIL" --role=author --path=/var/www/html --prompt=user_pass < /run/secrets/wp_user_password

# Bonus
runuser -u www-data -- wp plugin install redis-cache --activate --path=/var/www/html
runuser -u www-data -- wp config set WP_REDIS_HOST "redis" --path=/var/www/html
runuser -u www-data -- wp config set WP_REDIS_PORT "6379" --path=/var/www/html
runuser -u www-data -- wp redis enable --path=/var/www/html

# only exists if everything above worked.
touch /var/www/html/.setup_done
