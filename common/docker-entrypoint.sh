#!/bin/bash

/pre-run-checks.sh
# check output of pre-run-checks.sh for exit 0 or other

if [ $? -ne 0 ]; then
	echo "pre-run-checks.sh failed, exiting"
	exit 1
fi

if [ "$DOCKER_MAUTIC_ROLE" = "mautic_worker" ]; then
	/entrypoint_mautic_worker.sh
elif [ "$DOCKER_MAUTIC_ROLE" = "mautic_cron" ]; then
	/entrypoint_mautic_cron.sh
elif [ "$DOCKER_MAUTIC_ROLE" = "mautic_web" ]; then
	/entrypoint_mautic_web.sh "$@"
else
	echo "no entrypoint specified, exiting"
	exit 1
fi
