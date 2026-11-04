FROM debian:bookworm-20261027-slim

# While building use default answers for installs
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx openssl && \
    rm -rf /var/lib/apt/lists/*

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=700 ./tools/ /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/script.sh"]

EXPOSE 9000
