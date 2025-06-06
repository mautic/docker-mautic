#!/bin/bash

function check_environment_variables {

	for var in "${REQUIRED_MAUTIC_VARIABLES[@]}"; do
		if [ -z "${!var}" ]; then
			echo "error: ${var} is not set."
			exit 1
		fi
	done
}

check_environment_variables
