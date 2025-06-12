#!/bin/bash

function check_environment_variables {

	for var in "${REQUIRED_MAUTIC_VARIABLES[@]}"; do
		if [ -z "${!var}" ]; then
			echo "Startup Checks Error: ENV:${var} is not set." >&2
			echo "Please set the environment variable (usually found in .mautic_env) ${var} before starting the container." >&2
			exit 1
		fi
	done
}

check_environment_variables
