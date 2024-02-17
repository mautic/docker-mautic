#!/bin/bash

# wait until Mautic is installed
until php -r 'file_exists("/var/www/html/config/local.php") ? include("/var/www/html/config/local.php") : exit(1); exit(isset($parameters["site_url"]) ? 0 : 1);'; do
	echo "Mautic not installed, waiting to start workers"
	sleep 5
done

supervisord -c /etc/supervisor/conf.d/supervisord.conf
