# User documentation

## Services

| Service   | What it does                                  | Reachable from |
|-----------|-----------------------------------------------|----------------|
| nginx     | HTTPS front door (TLS 1.2/1.3) for the site   | host, port 443 |
| wordpress | The website and its admin panel (php-fpm)     | via nginx only |
| mariadb   | Database of the website                       | internal only  |
| redis     | Cache that speeds up WordPress (bonus)        | internal only  |
| ftp       | File transfer to the website files (bonus)    | host, port 21  |

## Start and stop

```sh
make          # build (first time) and start everything
make down     # stop and remove the containers (data is kept)
make re       # full reset: wipes ALL data, then rebuilds
```

## Access

Make sure `/etc/hosts` contains `127.0.0.1 ascheufe.42.fr`, then:

- Website: <https://ascheufe.42.fr>
- Administration panel: <https://ascheufe.42.fr/wp-admin> (browser warns about the
  self-signed certificate: accept it).
- FTP: `ftp ascheufe.42.fr`, user `ftpuser`, password from `secrets/ftp_user_password.txt`.
  You land in the WordPress folder and can upload/delete files.

## Credentials

Nothing sensitive is committed to Git. They are stored locally:

| What                         | Where                              |
|------------------------------|------------------------------------|
| Usernames, domain, DB name   | `srcs/.env`                        |
| WordPress administrator pw   | `secrets/wp_admin_password.txt`    |
| WordPress second user pw     | `secrets/wp_user_password.txt`     |
| Database user / root pw      | `secrets/db_password.txt`, `secrets/db_root_password.txt` |
| FTP password                 | `secrets/ftp_user_password.txt`    |

Usernames are `WP_ADMIN` (administrator) and `WP_USER` (author) in `srcs/.env`.
Passwords are only applied on the **first start**; to change them afterwards, change them
in WordPress itself, or run `make re` (this deletes all data).

## Check that everything works

```sh
make ps                                   # 5 containers should be "Up" (mariadb "healthy")
curl -kI https://ascheufe.42.fr           # HTTP/1.1 200 OK
docker exec wordpress wp redis status --path=/var/www/html --allow-root   # "Status: Connected"
make logs                                 # follow the logs of all services
```
