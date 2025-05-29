RESULT=$(chown -R $MAUTIC_WWW_USER:$MAUTIC_WWW_GROUP $MAUTIC_VOLUME_CONFIG $MAUTIC_VOLUME_LOGS $MAUTIC_VOLUME_MEDIA)
if [[ $? -ne 0 ]]; then
	echo "error: permissions for $MAUTIC_WWW_USER:$MAUTIC_WWW_GROUP could not be set."
	exit 1
fi
