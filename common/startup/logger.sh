#!/bin/bash

function log_startup_error_header {
  echo "----- Startup Checks Error Found -----" >&2
}

function log {
  echo "$@"
}

function log_debug {
  if [[ $DEBUG == "true" ]]; then
    echo "$@"
  fi
}

function log_error {
  echo "$@" >&2
}
