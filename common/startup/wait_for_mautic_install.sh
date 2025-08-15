#!/bin/bash

source /startup/logger.sh

function wait_for_mautic_install {
  local COUNTER=0
  until php -r "include('${MAUTIC_VOLUME_CONFIG}/local.php'); exit(!empty(\$parameters['db_driver']) && !empty(\$parameters['site_url']) ? 0 : 1);"; do
    log_debug "[${DOCKER_MAUTIC_ROLE}]: Waiting for Mautic to be installed, current attempt: ${COUNTER}."
    # only show message every 30 seconds (or DEBUG is enabled)
    if (( COUNTER % 6 == 0 )); then
      log "[${DOCKER_MAUTIC_ROLE}]: Waiting for Mautic to be installed, current attempt: ${COUNTER}."
    fi
    COUNTER=$((COUNTER + 1))
    sleep 5
  done
}

log_debug "[${DOCKER_MAUTIC_ROLE}]: Running wait for mautic install..."
wait_for_mautic_install
