#!/bin/bash

source /startup/logger.sh

function check_local_php_exists {
  # generate a local config file if it doesn't exist.
  # This is needed to ensure the db credentials can be prefilled in the UI, as env vars aren't taken into account.
  if [ ! -f "${MAUTIC_VOLUME_CONFIG}/local.php" ]; then
    log "${MAUTIC_VOLUME_CONFIG}/local.php was not found, creating a fresh local.php from the template."
    cp -p /templates/local.php "${MAUTIC_VOLUME_CONFIG}/local.php"
    chown "${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP}" "${MAUTIC_VOLUME_CONFIG}/local.php"
  fi
}

log_debug "Checking if local.php exists in ${MAUTIC_VOLUME_CONFIG}..."
check_local_php_exists
