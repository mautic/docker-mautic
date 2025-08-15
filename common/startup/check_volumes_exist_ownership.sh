#!/bin/bash

source /startup/logger.sh

function check_volumes_exist_ownership {
  local ERROR_FOUND=0
  for volume in ${MAUTIC_VOLUMES}; do
    if [[ ! -d "${volume}" ]]; then
      log_error "Error: ${volume} does not exist or is not a directory."
      ERROR_FOUND=1
    fi
  done

  if [[ $ERROR_FOUND -eq 1 ]]; then
    log_startup_error_header
    log_error "Please ensure the volume(s) is mounted correctly and is accessible."
    log_error "If you are running this container as a non-root user, you may need to run the container with elevated privileges."
    exit 1
  fi

  for perm_volume in ${MAUTIC_VOLUMES}; do
  # check ownership and assign ownership if not MAUTIC_WWW_USER:MAUTIC_WWW_GROUP
    if [[ $(stat -c '%U:%G' "${perm_volume}") != "${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP}" ]]; then
      chown -R "${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP}" "${perm_volume}" || {
        log_error "Error: Permissions for ${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP} could not be set on ${perm_volume}."
        ERROR_FOUND=1
      }
    fi
  done

  if [[ $ERROR_FOUND -eq 1 ]]; then
    log_startup_error_header
    log_error "Please ensure the volume(s) is mounted correctly and the ownership/perms are correctly configured (chown ${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP})."
    log_error "If you are running this container as a non-root user, you may need to run the container with elevated privileges."
    exit 1
  else
    log_debug "All required volumes exist and have correct ownership."
  fi
}

log_debug "Checking if required volumes exist and have correct ownership..."
check_volumes_exist_ownership
