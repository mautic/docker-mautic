#!/bin/bash
set -eu

# set a few variables to be used in the entrypoint scripts
export MAUTIC_VOLUME_CONFIG="${MAUTIC_VOLUME_CONFIG:-/var/www/html/config}"
export MAUTIC_VOLUME_LOGS="${MAUTIC_VOLUME_LOGS:-/var/www/html/var/logs}"
export MAUTIC_VOLUME_MEDIA="${MAUTIC_VOLUME_MEDIA:-/var/www/html/docroot/media}"

export MAUTIC_VAR="${MAUTIC_VAR:-/var/www/html/var}"
export MAUTIC_CONSOLE="${MAUTIC_CONSOLE:-/var/www/html/bin/console}"

export MAUTIC_WWW_USER="${MAUTIC_WWW_USER:-www-data}"
export MAUTIC_WWW_GROUP="${MAUTIC_WWW_GROUP:-www-data}"

export MAUTIC_VOLUMES=(
  "$MAUTIC_VOLUME_CONFIG"
  "$MAUTIC_VAR"
  # TODO consider adding var/* as volumes checks for future because they might need to exist but also have correct perms
  "$MAUTIC_VOLUME_LOGS"
  "$MAUTIC_VOLUME_MEDIA"
)

export REQUIRED_MAUTIC_VARIABLES=('MAUTIC_DB_HOST' 'MAUTIC_DB_PORT' 'MAUTIC_DB_USER' 'MAUTIC_DB_PASSWORD' 'DOCKER_MAUTIC_ROLE')

/startup/check_volumes_exist_ownership.sh
/startup/check_environment_variables.sh
/startup/check_database_connection.sh
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
