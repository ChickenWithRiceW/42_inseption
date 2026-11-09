FROM debian:bookworm-20261027-slim

# While building use default answers for installs
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        vsftpd \
    && rm -rf /var/lib/apt/lists/*


# COPY --chmod=700 ./tools/ /usr/local/bin/
COPY ./conf/vsftpd.conf /etc/vsftpd.conf
COPY --chmod=700 ./tools/script.sh /usr/local/bin/script.sh

EXPOSE 21
EXPOSE 40000-40010

ENTRYPOINT ["/usr/local/bin/script.sh"]
