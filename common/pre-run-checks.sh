#!/bin/bash

MAUTIC_VOLUME_CONFIG="${MAUTIC_VOLUME_CONFIG:-/var/www/html/config}"
MAUTIC_VOLUME_LOGS="${MAUTIC_VOLUME_LOGS:-/var/www/html/var/logs}"
MAUTIC_VOLUME_MEDIA="${MAUTIC_VOLUME_MEDIA:-/var/www/html/docroot/media}"

MAUTIC_WWW_USER="${MAUTIC_WWW_USER:-www-data}"
MAUTIC_WWW_GROUP="${MAUTIC_WWW_GROUP:-www-data}"

function check_volume {
	if [[ ! -d  $1 ]]; then
		echo "error: volume $1 does not exist or is not a directory."
		exit 1
	fi
}

############################
# check for required volumes
check_volume $MAUTIC_VOLUME_CONFIG
check_volume $MAUTIC_VOLUME_LOGS
check_volume $MAUTIC_VOLUME_MEDIA

############################
# check for permissions

RESULT=$(chown -R $MAUTIC_WWW_USER:$MAUTIC_WWW_GROUP $MAUTIC_VOLUME_CONFIG $MAUTIC_VOLUME_LOGS $MAUTIC_VOLUME_MEDIA)
if [[ $? -ne 0 ]]; then
	echo "error: permissions for $MAUTIC_WWW_USER:$MAUTIC_WWW_GROUP could not be set."
	exit 1
fi

################################################
# check for special MAUTIC_DB_*_FILE environment

# check if environment variable MAUTIC_DB_PASSWORD_FILE is set
if [[ ! -z $MAUTIC_DB_PASSWORD_FILE ]]; then
	echo "Trying to get db password from $MAUTIC_DB_PASSWORD_FILE"

	# check if password file exists
	if [[ -f "$MAUTIC_DB_PASSWORD_FILE" ]]; then
    	# try to read password from file
		PASSWORD_FROM_FILE=$(cat $MAUTIC_DB_PASSWORD_FILE)
		PASSWORD_FROM_FILE_STATUS=$?

		# check result
		if [[ $PASSWORD_FROM_FILE_STATUS -eq 0 ]]; then
			MAUTIC_DB_PASSWORD=$PASSWORD_FROM_FILE
			echo "Successfully read password from $MAUTIC_DB_PASSWORD_FILE"
		else
			echo "Warning: failed to read password from $MAUTIC_DB_PASSWORD_FILE, error code was ($PASSWORD_FROM_FILE_STATUS)"
		fi
	else
		echo "Warning: failed to read password. $MAUTIC_DB_PASSWORD_FILE is not a regular file"
	fi
fi

################################################
# check if all required environment variables exist

function check_environment_variables {
	local environment_variables=('MAUTIC_DB_HOST' 'MAUTIC_DB_PORT' 'MAUTIC_DB_USER' 'MAUTIC_DB_PASSWORD')

	for var in "${environment_variables[@]}"; do
		if [ -z "${!var}" ]; then
			echo "error: $var is not set."
			exit 1
		fi
	done
}

check_environment_variables

# wait until the db is fully up before proceeding
FAILURE_COUNT=0
MAX_FAILURE_COUNT=60
IS_ALIVE_COMMAND="mysqladmin --host=$MAUTIC_DB_HOST --port=$MAUTIC_DB_PORT --user=$MAUTIC_DB_USER --password=$MAUTIC_DB_PASSWORD ping"
IS_MYSQL_ALIVE=$($(echo $IS_ALIVE_COMMAND) 2>&1)
while [[ ${IS_MYSQL_ALIVE} != "mysqld is alive" ]]; do
	FAILURE_COUNT=$((FAILURE_COUNT + 1))
	if [[ $FAILURE_COUNT -gt $MAX_FAILURE_COUNT ]]; then
		echo "error: MySQL is not responding after $MAX_FAILURE_COUNT attempts. Exiting."
		exit 1
	fi

	if [[ $IS_MYSQL_ALIVE =~ "error" ]]; then
		echo "MySQL response contained error: $IS_MYSQL_ALIVE"
	else
		echo "MySQL is not ready yet, waiting..."
	fi
	sleep 1
	IS_MYSQL_ALIVE=$($(echo $IS_ALIVE_COMMAND) 2>&1)
done

# generate a local config file if it doesn't exist.
# This is needed to ensure the db credentials can be prefilled in the UI, as env vars aren't taken into account.
if [ ! -f $MAUTIC_VOLUME_CONFIG/local.php ]; then
	cp -p /local.php $MAUTIC_VOLUME_CONFIG/local.php
fi
