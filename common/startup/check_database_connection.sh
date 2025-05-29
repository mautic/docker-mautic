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
	IS_MYSQL_ALIVE=$(eval $IS_ALIVE_COMMAND 2>&1)
done
