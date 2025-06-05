#!/bin/bash

function check_local_php_exists {
# generate a local config file if it doesn't exist.
# This is needed to ensure the db credentials can be prefilled in the UI, as env vars aren't taken into account.
if [ ! -f $MAUTIC_VOLUME_CONFIG/local.php ]; then
	cp -p /templates/local.php $MAUTIC_VOLUME_CONFIG/local.php
fi

}

check_local_php
