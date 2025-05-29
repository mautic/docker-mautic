#!/bin/bash
set -eu

# set a few variables to be used in the entrypoint scripts
export MAUTIC_VOLUME_CONFIG="${MAUTIC_VOLUME_CONFIG:-/var/www/html/config}"
export MAUTIC_VOLUME_CONSOLE="${MAUTIC_VOLUME_CONFIG:-/var/www/html/bin/console}"
export MAUTIC_VOLUME_LOGS="${MAUTIC_VOLUME_LOGS:-/var/www/html/var/logs}"
export MAUTIC_VOLUME_MEDIA="${MAUTIC_VOLUME_MEDIA:-/var/www/html/docroot/media}"

export MAUTIC_WWW_USER="${MAUTIC_WWW_USER:-www-data}"
export MAUTIC_WWW_GROUP="${MAUTIC_WWW_GROUP:-www-data}"


/startup/check_local_php_exists.sh

if [ "$DOCKER_MAUTIC_ROLE" = "mautic_worker" ]; then
  /entrypoint_mautic_worker.sh
elif [ "$DOCKER_MAUTIC_ROLE" = "mautic_cron" ]; then
  /entrypoint_mautic_cron.sh
elif [ "$DOCKER_MAUTIC_ROLE" = "mautic_web" ]; then
  /entrypoint_mautic_web.sh "$@"
else
  echo "no entrypoint specified, exiting"
  exit 1
fi
