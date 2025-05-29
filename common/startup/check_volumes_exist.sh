function check_volume {
	if [[ ! -d  $1 ]]; then
		echo "error: volume $1 does not exist or is not a directory."
		exit 1
	fi
}

############################
# check for required volumes
check_volume $MAUTIC_VOLUME_CONFIG
check_volume $MAUTIC_VAR_DIR
check_volume $MAUTIC_VOLUME_LOGS
check_volume $MAUTIC_VOLUME_MEDIA
