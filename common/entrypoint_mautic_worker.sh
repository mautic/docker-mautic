#!/bin/bash

# wait until Mautic is installed
until php -r 'file_exists("/var/www/html/config/local.php") ? include("/var/www/html/config/local.php") : exit(1); exit(isset($parameters["site_url"]) ? 0 : 1);'; do
	echo "Mautic not installed, waiting to start workers"
	sleep 5
done

# Needed to finish the AWS SES plugin installation (started in Dockerfile)
php /var/www/html/bin/console cache:clear
php /var/www/html/bin/console mautic:plugins:reload

# Fix permissions (ilkkao)
chmod 777 /var/www/html/var/cache/prod/jms_serializer_default
mkdir -p /var/www/html/var/tmp/twig/
chmod 777 /var/www/html/var/tmp/twig/

supervisord -c /etc/supervisor/conf.d/supervisord.conf
