#!/bin/bash

mkdir -p /opt/mautic/cron

# wait until Mautic is installed
until php -r "include('$MAUTIC_VOLUME_CONFIG/local.php'); exit(isset(\$parameters['site_url']) ? 0 : 1);"; do
  echo "Mautic not installed, waiting to start cron"
  sleep 5
done

if [ ! -f /opt/mautic/cron/mautic  ]; then
  cp -p /templates/mautic_cron /opt/mautic/cron/mautic
fi

# register the crontab file for the www-data user
crontab -u www-data /opt/mautic/cron/mautic

# if /tmp/stdout exists clear it out
if [ ! -p /tmp/stdout ]; then
  rm -f /tmp/stdout
fi
# create the fifo file to be able to redirect cron output for non-root users
mkfifo /tmp/stdout
chmod 777 /tmp/stdout

# ensure the PHP env vars are present during cronjobs
declare -p | grep 'PHP_INI_VALUE_' > /tmp/cron.env

# run cron and print the output
cron -f | tail -f /tmp/stdout
