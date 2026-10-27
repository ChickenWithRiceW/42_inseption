FROM debian:bookworm

# Update OS
RUN apt update -y && apt upgrade -y

# Install mariaDB
RUN apt install -y mariadb-server mariadb-client

RUN rm -rf /var/lib/mysql/*
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

EXPOSE 3306

