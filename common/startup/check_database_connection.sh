#!/bin/bash

function check_database_connection {
	local IS_MYSQL_ALIVE=false
	local FAILURE_COUNT=0
	local MAX_FAILURE_COUNT=30
	function check_mysql_connection {
		IS_MYSQL_ALIVE=$(mysqladmin --host="$MAUTIC_DB_HOST" --port="$MAUTIC_DB_PORT" --user="$MAUTIC_DB_USER" --password="$MAUTIC_DB_PASSWORD" ping 2>&1)
	}

	check_mysql_connection
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

		# retry the connection
		check_mysql_connection
	done

}

check_database_connection
