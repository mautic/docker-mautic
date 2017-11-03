#!/bin/bash
set -e

if [ -n "$MYSQL_PORT_3306_TCP" ]; then
        if [ -z "$MAUTIC_DB_HOST" ]; then
                export MAUTIC_DB_HOST='mysql'
                if [ "$MAUTIC_DB_USER" = 'root' ] && [ -z "$MAUTIC_DB_PASSWORD" ]; then
                        export MAUTIC_DB_PASSWORD="$MYSQL_ENV_MYSQL_ROOT_PASSWORD"
                fi
        else
                echo >&2 "warning: both MAUTIC_DB_HOST and MYSQL_PORT_3306_TCP found"
                echo >&2 "  Connecting to MAUTIC_DB_HOST ($MAUTIC_DB_HOST)"
                echo >&2 "  instead of the linked mysql container"
        fi
fi

if [ -z "$MAUTIC_DB_HOST" ]; then
        echo >&2 "error: missing MAUTIC_DB_HOST and MYSQL_PORT_3306_TCP environment variables"
        echo >&2 "  Did you forget to --link some_mysql_container:mysql or set an external db"
        echo >&2 "  with -e MAUTIC_DB_HOST=hostname:port?"
        exit 1
fi


if [ -z "$MAUTIC_DB_PASSWORD" ]; then
        echo >&2 "error: missing required MAUTIC_DB_PASSWORD environment variable"
        echo >&2 "  Did you forget to -e MAUTIC_DB_PASSWORD=... ?"
        echo >&2
        echo >&2 "  (Also of interest might be MAUTIC_DB_USER and MAUTIC_DB_NAME.)"
        exit 1
fi

#ENABLES HUBSPOT CRON
if [ -n "$MAUTIC_CRON_HUBSPOT" ]; then
        echo >&2 "CRON: Activating Hubspot"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:fetchleads --integration=Hubspot > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
        echo "15,45 * * * *     www-data   php /var/www/html/app/console mautic:integration:pushactivity --integration=Hubspot > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
fi

#ENABLES SALESFORCE CRON
if [ -n "$MAUTIC_CRON_SALESFORCE" ]; then
        echo >&2 "CRON: Activating Salesforce"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:fetchleads --integration=Salesforce > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
        echo "12,42 * * * *     www-data   php /var/www/html/app/console mautic:integration:pushactivity --integration=Salesforce > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
        echo "14,44 * * * *     www-data   php /var/www/html/app/console mautic:integration:pushleadactivity --integration=Salesforce > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
        echo "16,46 * * * *     www-data   php /var/www/html/app/console mautic:integration:synccontacts --integration=Salesforce > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
fi

#ENABLES SUGARCRM CRON
if [ -n "$MAUTIC_CRON_SUGARCRM" ]; then
        echo >&2 "CRON: Activating SugarCRM"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:fetchleads --fetch-all --integration=Sugarcrm > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
fi

#ENABLES PIPEDRIVE CRON
if [ -n "$MAUTIC_CRON_PIPEDRIVE" ]; then
        echo >&2 "CRON: Activating Pipedrive"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:pipedrive:fetch > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
        echo "15,45 * * * *     www-data   php /var/www/html/app/console mautic:integration:pipedrive:push > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
fi

#ENABLES ZOHO CRON
if [ -n "$MAUTIC_CRON_ZOHO" ]; then
        echo >&2 "CRON: Activating ZohoCRM"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:fetchleads --integration=Zoho > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
fi

#ENABLES DYNAMICS CRON
if [ -n "$MAUTIC_CRON_DYNAMICS" ]; then
        echo >&2 "CRON: Activating DynamicsCRM"
        echo "10,40 * * * *     www-data   php /var/www/html/app/console mautic:integration:fetchleads -i Dynamics > /var/log/cron.pipe 2>&1" > /etc/cron.d/mautic
fi

if ! [ -e index.php -a -e app/AppKernel.php ]; then
        echo >&2 "Mautic not found in $(pwd) - copying now..."

        if [ "$(ls -A)" ]; then
                echo >&2 "WARNING: $(pwd) is not empty - press Ctrl+C now if this is an error!"
                ( set -x; ls -A; sleep 10 )
        fi

        tar cf - --one-file-system -C /usr/src/mautic . | tar xf -

        echo >&2 "Complete! Mautic has been successfully copied to $(pwd)"
fi

# Ensure the MySQL Database is created
php /makedb.php "$MAUTIC_DB_HOST" "$MAUTIC_DB_USER" "$MAUTIC_DB_PASSWORD" "$MAUTIC_DB_NAME"

echo >&2 "========================================================================"
echo >&2
echo >&2 "This server is now configured to run Mautic!"
echo >&2 "The following information will be prefilled into the installer (keep password field empty):"
echo >&2 "Host Name: $MAUTIC_DB_HOST"
echo >&2 "Database Name: $MAUTIC_DB_NAME"
echo >&2 "Database Username: $MAUTIC_DB_USER"
echo >&2 "Database Password: $MAUTIC_DB_PASSWORD"

# Write the database connection to the config so the installer prefills it
if ! [ -e app/config/local.php ]; then
        php /makeconfig.php

        # Make sure our web user owns the config file if it exists
        chown www-data:www-data app/config/local.php
        mkdir -p /var/www/html/app/logs
        chown www-data:www-data /var/www/html/app/logs
fi

if [[ "$MAUTIC_RUN_CRON_JOBS" == "true" ]]; then
    if [ ! -e /var/log/cron.pipe ]; then
        mkfifo /var/log/cron.pipe
        chown www-data:www-data /var/log/cron.pipe
    fi
    (tail -f /var/log/cron.pipe | while read line; do echo "[CRON] $line"; done) &
    CRONLOGPID=$!
    cron -f &
    CRONPID=$!
else
    echo >&2 "Not running cron as requested."
fi

echo >&2
echo >&2 "========================================================================"

if [ -n "$SYSTEM_TIMEZONE" ]; then
  echo >&2
  echo >&2 "Change Timezone to $SYSTEM_TIMEZONE"
  echo >&2
  export TZ="$SYSTEM_TIMEZONE";
fi

echo >&2
echo >&2 "System Timezone: "
echo >&2

cat /etc/timezone

echo >&2
echo >&2 "========================================================================"

"$@" &
MAINPID=$!

shut_down() {
    if [[ "$MAUTIC_RUN_CRON_JOBS" == "true" ]]; then
        kill -TERM $CRONPID || echo 'Cron not killed. Already gone.'
        kill -TERM $CRONLOGPID || echo 'Cron log not killed. Already gone.'
    fi
    kill -TERM $MAINPID || echo 'Main process not killed. Already gone.'
}
trap 'shut_down;' TERM INT

# wait until all processes end (wait returns 0 retcode)
while :; do
    if wait; then
        break
    fi
done
