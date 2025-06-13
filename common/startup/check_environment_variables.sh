#!/bin/bash

[[ $DEBUG -eq 1 ]] && echo "Running env var checks ${REQUIRED_MAUTIC_VARIABLES}"

function check_environment_variables {
	local ERROR_FOUND=0
	for m_var in ${REQUIRED_MAUTIC_VARIABLES}; do
		[[ $DEBUG -eq 1 ]] && echo "Checking if environment variable ${m_var} is set... ${m_var}=[${!m_var:-not set}]"
		if [ -z "${!m_var}" ]; then
			echo "ENV:${m_var} is not set." >&2
			ERROR_FOUND=1
		fi
	done

	if [[ $ERROR_FOUND -eq 1 ]]; then
		echo "----- Startup Checks Error Found -----" >&2
		echo "Please set the require environment variables (${REQUIRED_MAUTIC_VARIABLES}) exist (usually found in .mautic_env) before starting the container." >&2
		exit 1
	else
		[[ $DEBUG -eq 1 ]] && echo "All required environment variables are set."
	fi
}

check_environment_variables
