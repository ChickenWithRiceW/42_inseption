#!/bin/sh

set -eu

# Entry point script for setup decision.

if [ -f /var/www/html/.setup_done ]; then
	echo "[ENTRYPOINT] setup has been done before, nothing to do."
else
        echo "[ENTRYPOINT] first start, running setup"
	bash setup.sh
fi

# Replaces this shell with the real server (becomes pid1)
exec php-fpm8.2 -F
