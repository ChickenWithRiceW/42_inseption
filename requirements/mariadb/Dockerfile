FROM debian:bookworm

# Update OS
RUN apt update -y && apt upgrade -y

# Install mariaDB
RUN apt install -y mariadb-server mariadb-client

RUN rm -rf /var/lib/mysql/*
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

COPY ./tools/* /usr/local/bin/
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod +x /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/setup.sh
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/script.sh"]
