#!/bin/bash

function check_volumes_exist_ownership {
	for volume in "${MAUTIC_VOLUMES[@]}"; do
		if [[ ! -d "${volume}" ]]; then
			echo "error: ${volume} does not exist or is not a directory."
			exit 1
		fi

# check ownership and assign ownership if not MAUTIC_WWW_USER:MAUTIC_WWW_GROUP
		if [[ $(stat -c '%U:%G' "${volume}") != "${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP}" ]]; then
			chown -R "${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP}" "${volume}" || {
				echo "error: permissions for ${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP} could not be set."
				exit 1
			}
		fi
	done

}

check_volumes_exist_ownership
