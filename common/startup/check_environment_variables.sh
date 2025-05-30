function check_environment_variables {
	local environment_variables=('MAUTIC_DB_HOST' 'MAUTIC_DB_PORT' 'MAUTIC_DB_USER' 'MAUTIC_DB_PASSWORD' 'DOCKER_MAUTIC_ROLE')

	for var in "${environment_variables[@]}"; do
		if [ -z "${!var}" ]; then
			echo "error: $var is not set."
			exit 1
		fi
	done
}

check_environment_variables
