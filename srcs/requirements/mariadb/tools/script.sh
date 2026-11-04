#!/bin/sh

set -eu

# Entry point script for setup decision.

if [ -f /var/lib/mysql/.setup_done ]; then
	echo "[ENTRYPOINT] setup has been done before, nothing to do."
else
        echo "[ENTRYPOINT] first start, running setup"
	bash setup.sh
fi

# Replace this shell with the real server (becomes PID 1)
exec mysqld --user=mysql
