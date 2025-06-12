#!/bin/bash

function check_volumes_exist_ownership {
	for volume in "${MAUTIC_VOLUMES[@]}"; do
		if [[ ! -d "${volume}" ]]; then
			echo "error: ${volume} does not exist or is not a directory." >&2
			echo "Please ensure the volume is mounted correctly and is accessible." >&2
			echo "If you are running this container as a non-root user, you may need to run the container with elevated privileges." >&2
			exit 1
		fi

# check ownership and assign ownership if not MAUTIC_WWW_USER:MAUTIC_WWW_GROUP
		if [[ $(stat -c '%U:%G' "${volume}") != "${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP}" ]]; then
			chown -R "${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP}" "${volume}" || {
				echo "error: permissions for ${MAUTIC_WWW_USER}:${MAUTIC_WWW_GROUP} could not be set." >&2
				echo "Please ensure the user and group exist and have the correct permissions." >&2
				echo "If you are running this container as a non-root user, you may need to run the container with elevated privileges." >&2
				exit 1
			}
		fi
	done

}

check_volumes_exist_ownership
