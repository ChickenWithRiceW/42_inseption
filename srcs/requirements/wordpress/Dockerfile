FROM debian:bookworm-20261027-slim

# While building use default answers for installs
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        curl \
        ca-certificates \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# wp-cli is a single .phar file; this makes it a normal command called "wp"
RUN curl -fsSL -o /usr/local/bin/wp \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# php-fpm needs /run/php for its pid file, same idea as /run/mysqld
RUN mkdir -p /run/php /var/www/html && chown www-data:www-data /var/www/html

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/
COPY --chmod=700 ./tools/ /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/script.sh"]

EXPOSE 9000
