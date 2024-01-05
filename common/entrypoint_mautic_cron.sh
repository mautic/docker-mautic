#!/bin/bash

#[[ -f /opt/mautic/cron/mautic ]] || touch /opt/mautic/cron/mautic

# register the crontab file for the www-data user
crontab -u www-data /opt/mautic/cron/mautic

# create the fifo file to be able to redirect cron output for non-root users
mkfifo /tmp/stdout
chmod 777 /tmp/stdout

# ensure the PHP env vars are present during cronjobs
declare -p | grep 'PHP_INI_VALUE_' > /tmp/cron.env

cron -f | tail -f /tmp/stdout
