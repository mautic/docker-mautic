#!/bin/bash

source /startup/logger.sh

function check_database_connection {
  local FAILURE_COUNT=0
  local MAX_FAILURE_COUNT=31

  log_debug "Starting MySQL connection check (max attempts: ${MAX_FAILURE_COUNT})..."

  while [[ $FAILURE_COUNT -lt $MAX_FAILURE_COUNT ]]; do
    FAILURE_COUNT=$((FAILURE_COUNT + 1))

    # Try the connection using exit code
    if mysqladmin ping --host="${MAUTIC_DB_HOST}" --port="${MAUTIC_DB_PORT}" \
        --user="${MAUTIC_DB_USER}" --password="${MAUTIC_DB_PASSWORD}" &>/dev/null; then
      log_debug "MySQL is alive and reachable on attempt ${FAILURE_COUNT}/${MAX_FAILURE_COUNT}!"
      return 0
    else
      log "MySQL is not ready yet, waiting... Attempt ${FAILURE_COUNT}/${MAX_FAILURE_COUNT}"
    fi

    sleep 1
  done

  # Max attempts reached
  log_startup_error_header
  log_error "MySQL is not responding after ${MAX_FAILURE_COUNT} attempts. Exiting."
  log_error "Please ensure the MySQL server is running and accessible from this container."
  exit 1
}

log_debug "Checking database connection is alive and well..."
check_database_connection
