FROM debian:bookworm-20261027-slim

# While building use default answers for installs
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        mariadb-server mariadb-client \
    && rm -rf /var/lib/apt/lists/* /var/lib/mysql/* \
    && mkdir -p /run/mysqld \
    && chown mysql:mysql /run/mysqld


COPY ./tools/ /usr/local/bin/
RUN chmod 700 /usr/local/bin/*.sh
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/script.sh"]
