# Developer documentation

## Set up from scratch

Prerequisites: Linux VM, Docker Engine + Compose plugin, `make`, `sudo`.

```sh
cp srcs/.env.example srcs/.env            # then edit
mkdir -p secrets
for s in db_password db_root_password wp_admin_password wp_user_password ftp_user_password; do
  openssl rand -base64 18 > secrets/$s.txt
done
echo "127.0.0.1 ascheufe.42.fr" | sudo tee -a /etc/hosts
```

- `srcs/.env` – variables read by the containers (`env_file`): `DOMAIN_NAME`,
  `MYSQL_DATABASE`, `MYSQL_USER`, `WP_TITEL`, `WP_ADMIN`, `WP_ADMIN_EMAIL`, `WP_USER`,
  `WP_USER_EMAIL`. The admin login must not contain "admin"/"administrator".
- `secrets/*.txt` – declared in the `secrets:` block of `docker-compose.yml` and mounted
  at `/run/secrets/<name>`. Both `.env` and `secrets/` are git-ignored: never commit them.
- The login (`ascheufe`) is used in the `Makefile` (`LOGIN`) and in the volume `device:`
  paths of `docker-compose.yml`; change both if your login differs.

## Build and launch

```sh
make              # mkdir the data folders, then docker compose up -d --build
make down         # docker compose down
make clean        # down + remove images and volumes (host data kept)
make fclean       # clean + delete /home/ascheufe/data/*
make re           # fclean + all
```

Equivalent: `docker compose -f srcs/docker-compose.yml up -d --build`.

## Useful commands

```sh
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker exec -it mariadb mysql -uroot -p        # root password: secrets/db_root_password.txt
docker exec wordpress wp user list --path=/var/www/html --allow-root
docker volume ls && docker volume inspect srcs_wordpress_data
docker network inspect srcs_inseption_net
```

## Where data lives and how it persists

| Volume           | Container path     | Host path                          |
|------------------|--------------------|------------------------------------|
| `mariadb_data`   | `/var/lib/mysql`   | `/home/ascheufe/data/mysql`        |
| `wordpress_data` | `/var/www/html`    | `/home/ascheufe/data/wordpress`    |

Both are Docker *named volumes* (`local` driver with `driver_opts` pointing at the host
path), shared as follows: wordpress (rw), nginx (ro), ftp (rw). Data survives
`make down` and container crashes. Setup is idempotent: the entrypoints create a marker
file (`.setup_done`) once the first-start configuration succeeded; if it is missing
(e.g. half-finished setup) the setup is rerun from a clean directory. Delete the data
(`make fclean`) to force a fresh install.

## Design notes

- Entrypoints end with `exec <daemon>` so the daemon is PID 1 and receives signals;
  no `tail -f`/`sleep infinity` loops. `restart: always` restarts crashed containers.
- `wordpress` waits for `mariadb` to be healthy (`mysqladmin ping`) before installing.
- Only nginx publishes 443 (FTP 21 + passive 40000-40010 for the bonus).
