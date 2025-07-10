#!/bin/bash

source /startup/logger.sh

function check_environment_variables {
  local ERROR_FOUND=0
  for m_var in ${REQUIRED_MAUTIC_VARIABLES}; do
    log_debug "Checking if environment variable ${m_var} is set... ${m_var}=[${!m_var:-not set}]"
    if [ -z "${!m_var}" ]; then
      log_error "ENV:${m_var} is not set."
      ERROR_FOUND=1
    fi
  done

  if [[ $ERROR_FOUND -eq 1 ]]; then
    log_startup_error_header
    log_error "Please set the require environment variables (${REQUIRED_MAUTIC_VARIABLES}) exist (usually found in .mautic_env) before starting the container."
    exit 1
  else
    log_debug "All required environment variables are set."
  fi
}

log_debug "Running env var checks ${REQUIRED_MAUTIC_VARIABLES}"
check_environment_variables
