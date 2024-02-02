#!/bin/bash

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
