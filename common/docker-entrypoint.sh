#!/bin/bash
set -e

export DEBUG=${DEBUG:="false"}
source /startup/logger.sh
log_debug "Startup Debug Logging Enabled."

# default the db port to 3306 if not set
export MAUTIC_DB_PORT="${MAUTIC_DB_PORT:-3306}"

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
    log_startup_error_header
    log_error "DOCKER_MAUTIC_ROLE was found to be \"${DOCKER_MAUTIC_ROLE}\" which is not one of the valid values (mautic_web, mautic_cron, mautic_worker), exiting"
    exit 1
    ;;
esac
