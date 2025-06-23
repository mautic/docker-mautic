#!/bin/bash

function check_volumes_exist_ownership {
    local VOLUME_ERROR_FOUND=0
  for volume in ${MAUTIC_VOLUMES}; do
    if [[ ! -d "${volume}" ]]; then
      echo "Error: ${volume} does not exist or is not a directory."
      VOLUME_ERROR_FOUND=1
    fi
  done

  if [[ $VOLUME_ERROR_FOUND -eq 1 ]]; then
    echo "----- Startup Checks Error Found -----" >&2
    echo "Please ensure the volume(s) are mounted correctly and is accessible." >&2
    echo "If you are running this container as a non-root user, you may need to run the container with elevated privileges." >&2
    exit 1
  fi

  PERM_ERROR_FOUND=0
  local VOLUME_PERMISSIONS_FAILURE_MESSAGE
  for perm_volume in ${MAUTIC_VOLUMES}; do
  # check ownership and assign ownership if not MAUTIC_WWW_USER:MAUTIC_WWW_GROUP
    if [[ $(stat -c '%U:%G' "${perm_volume}") != "${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP}" ]]; then
      chown -R "${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP}" "${perm_volume}" || {
        echo "Error: Permissions for ${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP} could not be set on ${perm_volume}." >&2
        PERM_ERROR_FOUND=1
      }
    fi
  done

  if [[ $PERM_ERROR_FOUND -eq 1 ]]; then
    echo "----- Startup Checks Error Found -----" >&2
    echo "Please ensure the volume(s) is mounted correctly and the ownership/perms are correctly configured (chown ${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP})." >&2
    echo "If you are running this container as a non-root user, you may need to run the container with elevated privileges." >&2
    exit 1
  else
    [[ $DEBUG -eq 1 ]] && echo "All required volumes exist and have correct ownership."
  fi
}


[[ $DEBUG -eq 1 ]] && echo "Checking if required volumes exist and have correct ownership..."
check_volumes_exist_ownership
