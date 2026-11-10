*This project has been created as part of the 42 curriculum by ascheufe.*

# Inception

## Description

Inception is a system-administration project: a small web infrastructure built from
scratch with Docker Compose inside a virtual machine. Every service runs in its own
container, built from our own Dockerfiles on top of `debian:bookworm` (the penultimate
Debian stable release). No ready-made images are pulled.

| Service     | Role                                                              |
|-------------|-------------------------------------------------------------------|
| `nginx`     | Only entry point, port **443**, TLSv1.2 / TLSv1.3 only            |
| `wordpress` | WordPress + php-fpm (no web server), configured with wp-cli       |
| `mariadb`   | WordPress database (no web server)                                |
| `redis`     | *Bonus* – object cache for WordPress                              |
| `ftp`       | *Bonus* – vsftpd, serves the WordPress volume                     |

Two named volumes (`mariadb_data`, `wordpress_data`) keep their data in
`/home/ascheufe/data/{mysql,wordpress}` on the host, and a dedicated bridge network
(`inseption_net`) connects the containers. All containers restart automatically on a crash.

```
 browser ──443/TLS──> nginx ──fastcgi:9000──> wordpress ──3306──> mariadb
                         │                        └────6379────> redis
                         └── wordpress_data (ro)  ftp ── wordpress_data (rw)
```

### Sources

- `Makefile` – entry point (`make`, `make down`, `make re`, ...).
- `srcs/docker-compose.yml` – services, volumes, network, secrets.
- `srcs/requirements/<service>/` – `Dockerfile`, `conf/` (configuration files) and
  `tools/` (entrypoint / setup scripts) for each service; bonus services in `bonus/`.
- `secrets/` and `srcs/.env` – **not committed** (see `.gitignore`); see `DEV_DOC.md`.

### Design choices and comparisons

**Virtual Machines vs Docker.** A VM virtualises hardware and runs a full guest OS
(heavy, slow to boot, strong isolation). A container shares the host kernel and isolates
only processes, filesystem and network: it starts in a second, is tiny and reproducible
from a Dockerfile, but isolation is weaker. Here the VM hosts Docker, and Docker splits
the stack into single-purpose containers.

**Secrets vs Environment Variables.** Environment variables (`srcs/.env`) are fine for
non-sensitive configuration (domain, usernames, DB name) but are visible in
`docker inspect` and inherited by child processes. Docker secrets are mounted as files in
`/run/secrets/` (only in the containers that need them), never appear in the image or in
the environment. All passwords therefore use secrets; the `.env` file holds no password.

**Docker Network vs Host Network.** With `network_mode: host` a container shares the
host's network stack: no isolation, port clashes, and it is forbidden by the subject. A
user-defined bridge network gives each container its own address, DNS resolution by
service name (`mariadb`, `redis`, `wordpress`) and exposes only what we publish
(443, plus FTP for the bonus).

**Docker Volumes vs Bind Mounts.** Bind mounts map an arbitrary host path and depend on
the host's layout; named volumes are managed by Docker (listed with `docker volume ls`,
portable, backed up and removed with the CLI). The subject requires named volumes, so we
declare them with the `local` driver and `driver_opts` (`type: none`, `o: bind`) which
makes Docker store their data in `/home/ascheufe/data` while they remain named volumes.

## Instructions

Prerequisites: a Linux VM with Docker Engine and the Docker Compose plugin, `make`, and
`sudo` (only for `make fclean`).

1. Create the configuration (not versioned):
   - `srcs/.env` – copy `srcs/.env.example`.
   - `secrets/db_password.txt`, `db_root_password.txt`, `wp_admin_password.txt`,
     `wp_user_password.txt`, `ftp_user_password.txt` – one password per file.
2. Point the domain to the VM: add `127.0.0.1 ascheufe.42.fr` to `/etc/hosts`.
3. Build and start: `make`
4. Open <https://ascheufe.42.fr> (accept the self-signed certificate).

Other targets: `make down`, `make clean`, `make fclean` (also deletes the data), `make re`,
`make ps`, `make logs`. See `USER_DOC.md` and `DEV_DOC.md` for details.

## Resources

- Docker docs: <https://docs.docker.com/> (Dockerfile best practices, Compose file reference, secrets, volumes)
- NGINX: <https://nginx.org/en/docs/> and <https://nginx.org/en/docs/http/ngx_http_ssl_module.html>
- PHP-FPM: <https://www.php.net/manual/en/install.fpm.configuration.php>
- WP-CLI: <https://wp-cli.org/> – MariaDB: <https://mariadb.com/kb/en/documentation/>
- Redis: <https://redis.io/docs/> – Redis Object Cache plugin: <https://wordpress.org/plugins/redis-cache/>
- vsftpd: <https://security.appspot.com/vsftpd/vsftpd_conf.html>
- "PID 1 and signal handling in containers" articles (why `exec` is used in entrypoints).

### Use of AI

AI (Claude) was used to review the finished project against the subject, to run the stack
and test it (TLS versions, restart policy, persistence, FTP, Redis), and to help draft this
documentation and fix the issues found (Makefile default target, redis/nginx `EXPOSE`,
read-only FTP volume, passwords echoed in logs, `https` site URL). Every change was
reviewed and tested by the author, who is able to explain it.
