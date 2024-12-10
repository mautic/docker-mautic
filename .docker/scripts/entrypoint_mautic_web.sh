#!/bin/bash

chown -R www-data:www-data /var/www/html/config /var/www/html/var/logs /var/www/html/docroot/media

# wait untill the db is fully up before proceeding
while [[ $(mysqladmin --host=$MAUTIC_DB_HOST --port=$MAUTIC_DB_PORT --user=$MAUTIC_DB_USER --password=$MAUTIC_DB_PASSWORD ping) != "mysqld is alive" ]]; do
	sleep 1
done

# generate a local config file if it doesn't exist.
# This is needed to ensure the db credentials can be prefilled in the UI, as env vars aren't taken into account.
if [ ! -f /var/www/html/config/local.php ]; then

	su -s /bin/bash www-data -c 'touch /var/www/html/config/local.php'

	cat <<'EOF' > /var/www/html/config/local.php
<?php
$parameters = array(
	'db_driver' => 'pdo_mysql',
	'db_host' => getenv('MAUTIC_DB_HOST'),
	'db_port' => getenv('MAUTIC_DB_PORT'),
	'db_name' => getenv('MAUTIC_DB_DATABASE'),
	'db_user' => getenv('MAUTIC_DB_USER'),
	'db_password' => getenv('MAUTIC_DB_PASSWORD'),
	'db_table_prefix' => null,
	'db_backup_tables' => 1,
	'db_backup_prefix' => 'bak_',
);
EOF
fi

# prepare mautic with test data
if [ "$DOCKER_MAUTIC_LOAD_TEST_DATA" = "true" ]; then
	su -s /bin/bash www-data -c 'php /var/www/html/bin/console doctrine:migrations:sync-metadata-storage'
	# mautic installation with dummy password and email, as the next step (doctrine:fixtures:load) will overwrite those
	su -s /bin/bash www-data -c 'php /var/www/html/bin/console mautic:install --force --admin_email willchange@mautic.org --admin_password willchange http://localhost'
	su -s /bin/bash www-data -c 'php /var/www/html/bin/console doctrine:fixtures:load -n'
fi

# run migrations
if [ "$DOCKER_MAUTIC_RUN_MIGRATIONS" = "true" ]; then
	su -s /bin/bash www-data -c 'php /var/www/html/bin/console doctrine:migration:migrate -n'
fi

# execute the provided entrypoint
"$@"
