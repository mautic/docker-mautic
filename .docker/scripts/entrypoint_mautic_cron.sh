#!/bin/bash

mkdir -p /opt/mautic/cron

if [ ! -f /opt/mautic/cron/mautic ]; then

	cat <<EOF > /opt/mautic/cron/mautic
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
BASH_ENV=/tmp/cron.env

* * * * * php /var/www/html/bin/console mautic:segments:update 2>&1 | tee /tmp/stdout
* * * * * php /var/www/html/bin/console mautic:campaigns:update 2>&1 | tee /tmp/stdout
* * * * * php /var/www/html/bin/console mautic:campaigns:trigger 2>&1 | tee /tmp/stdout

EOF
fi

# register the crontab file for the www-data user
crontab -u www-data /opt/mautic/cron/mautic

# create the fifo file to be able to redirect cron output for non-root users
mkfifo /tmp/stdout
chmod 777 /tmp/stdout

# ensure the PHP env vars are present during cronjobs
declare -p | grep 'PHP_INI_VALUE_' > /tmp/cron.env

# wait until Mautic is installed
until php -r 'file_exists("/var/www/html/config/local.php") ? include("/var/www/html/config/local.php") : exit(1); exit(isset($parameters["site_url"]) ? 0 : 1);'; do
	echo "Mautic not installed, waiting to start cron"
	sleep 5
done

# run cron and print the output
cron -f | tail -f /tmp/stdout
