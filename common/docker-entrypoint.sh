#!/bin/bash
set -eu

# DEBUG flag to enable debug output. To turn on debug set DEBUG=1 (e.g. docker compose up -d --build --env DEBUG=1)
TEMP_DEBUG="${DEBUG:-0}"
if [[ "$TEMP_DEBUG" == "1" || "${TEMP_DEBUG:-0}" == "true" || "${TEMP_DEBUG:-1}" -eq 1 ]]; then
  echo "Startup debug logging enabled."
  DEBUG=1
else
  DEBUG=0
fi
export DEBUG

# set a few variables to be used in the entrypoint scripts
export MAUTIC_VOLUME_CONFIG="${MAUTIC_VOLUME_CONFIG:-/var/www/html/config}"
export MAUTIC_VOLUME_LOGS="${MAUTIC_VOLUME_LOGS:-/var/www/html/var/logs}"
export MAUTIC_VOLUME_MEDIA="${MAUTIC_VOLUME_MEDIA:-/var/www/html/docroot/media}"

export MAUTIC_VAR="${MAUTIC_VAR:-/var/www/html/var}"
export MAUTIC_CONSOLE="${MAUTIC_CONSOLE:-/var/www/html/bin/console}"

export MAUTIC_WWW_USER="${MAUTIC_WWW_USER:-www-data}"
export MAUTIC_WWW_GROUP="${MAUTIC_WWW_GROUP:-www-data}"

# TODO consider adding "var/*" as volumes checks for future because they might need to exist but also have correct perms
export MAUTIC_VOLUMES="\
${MAUTIC_VOLUME_CONFIG} \
${MAUTIC_VAR} \
${MAUTIC_VOLUME_LOGS} \
${MAUTIC_VOLUME_MEDIA}"

export REQUIRED_MAUTIC_VARIABLES="\
MAUTIC_DB_HOST \
MAUTIC_DB_USER \
MAUTIC_DB_PASSWORD \
DOCKER_MAUTIC_ROLE"

/startup/check_volumes_exist_ownership.sh
/startup/check_environment_variables.sh
/startup/check_database_connection.sh
/startup/check_local_php_exists.sh


COUNTER=0
# if it is a cron/worker we will wait for mautic to be installed before starting
if [[ "${DOCKER_MAUTIC_ROLE}" == "mautic_cron" || "${DOCKER_MAUTIC_ROLE}" == "mautic_worker" ]]; then
  # wait until Mautic is installed
  until php -r "include('${MAUTIC_VOLUME_CONFIG}/local.php'); exit(isset(\$parameters['site_url']) ? 0 : 1);"; do
    # only show message every 30 seconds (or DEBUG is enabled)
    if (( COUNTER % 6 == 0 || $DEBUG -eq 1 )); then
      echo "[${DOCKER_MAUTIC_ROLE}]: Waiting for Mautic to be installed, current attempt: ${COUNTER}."
    fi
    COUNTER=$((COUNTER + 1))
    sleep 5
  done
fi


case "${DOCKER_MAUTIC_ROLE}" in
  mautic_web)
    /entrypoint_mautic_web.sh "$@"
    ;;
  mautic_cron)
    /entrypoint_mautic_cron.sh
    ;;
  mautic_worker)
    /entrypoint_mautic_worker.sh
    ;;
  *)
		echo "----- Startup Checks Error Found -----" >&2
    echo "DOCKER_MAUTIC_ROLE was found to be \"${DOCKER_MAUTIC_ROLE}\" which is not one of the valid values (mautic_web, mautic_cron, mautic_worker), exiting" >&2
    exit 1
    ;;
esac
