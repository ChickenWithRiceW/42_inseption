FROM debian:bookworm

# Update OS
RUN apt update -y && apt upgrade -y

# Install mariaDB
RUN apt install -y mariadb-server mariadb-client

RUN rm -rf /var/lib/mysql/*
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

COPY ./tools/* /usr/local/bin/
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

