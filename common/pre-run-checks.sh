#!/bin/bash
set -eu

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

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$DOCKER_XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
function file_env {
	local var="$1"
	local fileVar="DOCKER_${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}


################################################
# check if all required environment variables exist

file_env 'MAUTIC_DB_HOST'
file_env 'MAUTIC_DB_PORT'
file_env 'MAUTIC_DB_USER'
file_env 'MAUTIC_DB_PASSWORD'
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
MAX_FAILURE_COUNT=30
IS_ALIVE_COMMAND="mysqladmin --host=$MAUTIC_DB_HOST --port=$MAUTIC_DB_PORT --user=$MAUTIC_DB_USER --password=$MAUTIC_DB_PASSWORD ping"
IS_MYSQL_ALIVE=$(eval $IS_ALIVE_COMMAND 2>&1)
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
