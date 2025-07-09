#!/bin/bash

source /startup/logger.sh

function check_database_connection {
  local IS_MYSQL_ALIVE=false
  local FAILURE_COUNT=0
  local MAX_FAILURE_COUNT=31

  while [[ "${IS_MYSQL_ALIVE}" != "mysqld is alive" ]]; do
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
    if [[ $FAILURE_COUNT -gt $MAX_FAILURE_COUNT ]]; then
      log_startup_error_header
      log_error "MySQL is not responding after ${MAX_FAILURE_COUNT} attempts. Exiting."
      log_error "Please ensure the MySQL server is running and accessible from this container."
      exit 1
    fi

    if [[ "${IS_MYSQL_ALIVE}" =~ "error" ]]; then
      log_error "MySQL response contained error: ${IS_MYSQL_ALIVE}"
      log "We will continue to retry the connection."
    else
      log "MySQL is not ready yet, waiting..."
    fi
    sleep 1

    # try the connection
    log_debug "Checking DB connection to ${MAUTIC_DB_HOST}:${MAUTIC_DB_PORT} with user ${MAUTIC_DB_USER}"
    IS_MYSQL_ALIVE=$(mysqladmin --host="${MAUTIC_DB_HOST}" --port="${MAUTIC_DB_PORT}" --user="${MAUTIC_DB_USER}" --password="${MAUTIC_DB_PASSWORD}" ping 2>&1)
  done

  # we either maxed our connection attempts or we got a successful response
  log_debug "MySQL connection check response: ${IS_MYSQL_ALIVE}"
  if [[ "${IS_MYSQL_ALIVE}" == "mysqld is alive" ]]; then
    log_debug "MySQL is alive and well."
  fi
}

log_debug "Checking database connection is alive and well..."
check_database_connection
