#!/bin/bash
set -e

if [ ! -f /usr/local/etc/php/php.ini ]; then
cat <<EOF > /usr/local/etc/php/php.ini
date.timezone = "${PHP_INI_DATE_TIMEZONE}"
always_populate_raw_post_data = -1
zend.assertions = -1
memory_limit = ${PHP_MEMORY_LIMIT}
file_uploads = On
upload_max_filesize = ${PHP_MAX_UPLOAD}
post_max_size = ${PHP_MAX_UPLOAD}
max_execution_time = ${PHP_MAX_EXECUTION_TIME}
EOF
fi

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
        echo "10,40 * * * *     www-data   php /var/www/html/bin/console mautic:integration:fetchleads --integration=Hubspot > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
        echo "15,45 * * * *     www-data   php /var/www/html/bin/console mautic:integration:pushactivity --integration=Hubspot > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES SALESFORCE CRON
if [ -n "$MAUTIC_CRON_SALESFORCE" ]; then
        echo >&2 "CRON: Activating Salesforce"
        echo "10,40 * * * *     www-data   php /var/www/html/bin/console mautic:integration:fetchleads --integration=Salesforce > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
        echo "12,42 * * * *     www-data   php /var/www/html/bin/console mautic:integration:pushactivity --integration=Salesforce > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
        echo "14,44 * * * *     www-data   php /var/www/html/bin/console mautic:integration:pushleadactivity --integration=Salesforce > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
        echo "16,46 * * * *     www-data   php /var/www/html/bin/console mautic:integration:synccontacts --integration=Salesforce > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES SUGARCRM CRON
if [ -n "$MAUTIC_CRON_SUGARCRM" ]; then
        echo >&2 "CRON: Activating SugarCRM"
        echo "10,40 * * * *     www-data   php /var/www/html/bin/console mautic:integration:fetchleads --fetch-all --integration=Sugarcrm > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES PIPEDRIVE CRON
if [ -n "$MAUTIC_CRON_PIPEDRIVE" ]; then
        echo >&2 "CRON: Activating Pipedrive"
        echo "10,40 * * * *     www-data   php /var/www/html/bin/console mautic:integration:pipedrive:fetch > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
        echo "15,45 * * * *     www-data   php /var/www/html/bin/console mautic:integration:pipedrive:push > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES ZOHO CRON
if [ -n "$MAUTIC_CRON_ZOHO" ]; then
        echo >&2 "CRON: Activating ZohoCRM"
        echo "10,40 * * * *     www-data   php /var/www/html/bin/console mautic:integration:fetchleads --integration=Zoho > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
fi

#ENABLES DYNAMICS CRON
if [ -n "$MAUTIC_CRON_DYNAMICS" ]; then
        echo >&2 "CRON: Activating DynamicsCRM"
        echo "10,40 * * * *     www-data   php /var/www/html/bin/console mautic:integration:fetchleads -i Dynamics > /var/log/cron.pipe 2>&1" >> /etc/cron.d/mautic
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
echo >&2 "This server is now configured to run Mautic!"
echo >&2 "The following information will be prefilled into the installer (keep password field empty):"
echo >&2 "Host Name: $MAUTIC_DB_HOST"
echo >&2 "Database Name: $MAUTIC_DB_NAME"
echo >&2 "Database Username: $MAUTIC_DB_USER"
echo >&2 "Database Password: $MAUTIC_DB_PASSWORD"
echo >&2 "========================================================================"
echo >&2
echo >&2

# Write the provided configuration to the config so the installer prefills it
echo >&2 "========================================================================"
php /makeconfig.php
echo >&2 "========================================================================"
echo >&2
echo >&2

# Make sure our web user owns the config file
chown www-data:www-data app/config/local.php

# Make sure logs exists and is owned by www-data
mkdir -p /var/www/html/app/logs
chown -R www-data:www-data /var/www/html/app/logs

# Make sure cache exists and is owned by www-data
mkdir -p /var/www/html/var/cache/prod
chown -R www-data:www-data /var/www/html/var/cache

if ! grep -Fq "secret_key" /var/www/html/app/config/local.php; then
  echo >&2 "========================================================================"
  echo >&2 "Mautic not currently installed (no secret_key in local.php)"
  echo >&2

  if [ -n "$MAUTIC_URL" ] && [ -n "$MAUTIC_ADMIN_EMAIL" ] && [ -n "$MAUTIC_ADMIN_PASSWORD" ]; then

    echo >&2 "URL & Admin credentials supplied, attempting automated mautic installation."
    echo >&2

    INSTALL_PARAMS=("$MAUTIC_URL")

    if [ -n "$MAUTIC_INSTALL_FORCE" ]; then
      INSTALL_PARAMS+=(-f)
    else
      if ! [[ $MAUTIC_URL =~ https://.* ]]; then
        echo >&2 "URL not using HTTPS and MAUTIC_INSTALL_FORCE not provided.  please provide"
        echo >&2 "a https url or set MAUTIC_INSTALL_FORCE true to continue."
        echo >&2
        echo >&2 "========================================================================"
        sleep 5
        exit 1
      fi
    fi

    if [ -n "$MAUTIC_ADMIN_USERNAME" ]; then
      INSTALL_PARAMS+=(--admin_username="$MAUTIC_ADMIN_USERNAME")
    fi
    if [ -n "$MAUTIC_ADMIN_FIRSTNAME" ]; then
      INSTALL_PARAMS+=(--admin_firstname="$MAUTIC_ADMIN_FIRSTNAME")
    fi
    if [ -n "$MAUTIC_ADMIN_LASTNAME" ]; then
      INSTALL_PARAMS+=(--admin_lastname="$MAUTIC_ADMIN_LASTNAME")
    fi

    sudo -Eu www-data php /var/www/html/bin/console mautic:install ${INSTALL_PARAMS[@]}
  else
    echo >&2 "URL & Admin credentials not supplied, please install mautic manually."
  fi
  echo >&2 "========================================================================"
  echo >&2
  echo >&2
fi

# clear mautic cache
sudo -Eu www-data php /var/www/html/bin/console mautic:cache:clear

if [[ "$MAUTIC_RUN_MIGRATIONS" == "true" ]]; then
    echo >&2 "========================================================================"
    echo >&2 "Applying any needed database migrations"
    echo >&2
    sudo -Eu www-data php /var/www/html/bin/console doctrine:migration:migrate -n
    echo >&2 "========================================================================"
    echo >&2
    echo >&2
fi

# if we have the credentials to do a maxmind download
if grep -Fq "'ip_lookup_auth' => '" /var/www/html/app/config/local.php; then
  echo >&2 "========================================================================"
  echo >&2 "Grabbing latest ip lookup database"
  echo >&2
  sudo -Eu www-data php /var/www/html/bin/console mautic:iplookup:download
  echo >&2 "========================================================================"
  echo >&2
  echo >&2
fi

if [[ "$MAUTIC_RUN_CRON_JOBS" == "true" ]]; then
  echo >&2 "========================================================================"
  echo >&2 "Activating cron"
  if [ ! -e /var/log/cron.pipe ]; then
      mkfifo /var/log/cron.pipe
      chown www-data:www-data /var/log/cron.pipe
  fi
  (tail -f /var/log/cron.pipe | while read line; do echo "[CRON] $line"; done) &
  CRONLOGPID=$!
  cron -f &
  CRONPID=$!
  echo >&2 "========================================================================"
  echo >&2
  echo >&2
else
  echo >&2 "========================================================================"
  echo >&2 "Not running cron"
  echo >&2 "========================================================================"
  echo >&2
  echo >&2
fi

echo >&2 "========================================================================"
echo >&2 "Starting mautic"
echo >&2 "========================================================================"
echo >&2
echo >&2

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
