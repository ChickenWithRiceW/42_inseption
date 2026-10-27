#!/bin/sh

# Entry point script for setup decision.

if [ -f /var/lib/mysql/.setup_done ]; then
	echo "[ENTRYPOINT] setup has been done before, nothing to do."
	exec mysqld --user=mysql
else
        echo "[ENTRYPOINT] first start, running setup"
	bash setup.sh
fi
