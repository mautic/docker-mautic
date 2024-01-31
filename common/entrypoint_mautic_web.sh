#!/bin/bash

chown -R www-data:www-data /var/www/html/config /var/www/html/var/logs /var/www/html/docroot/media

# wait untill the db is fully up before proceeding
while [[ $(mysqladmin --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD ping) != "mysqld is alive" ]]; do
	sleep 1
done

# generate a local config file if it does't exist
if [ ! -f /var/www/html/config/local.php ]; then

	su -s /bin/bash www-data -c 'touch /var/www/html/config/local.php'

	cat <<'EOF' > /var/www/html/config/local.php
<?php
$parameters = array(
	'db_driver' => 'pdo_mysql',
	'db_host' => getenv('MYSQL_HOST'),
	'db_port' => getenv('MYSQL_PORT'),
	'db_name' => getenv('MYSQL_DATABASE'),
	'db_user' => getenv('MYSQL_USER'),
	'db_password' => getenv('MYSQL_PASSWORD'),
	'db_table_prefix' => null,
	'db_backup_tables' => 1,
	'db_backup_prefix' => 'bak_',
	'messenger_dsn_email' => 'doctrine://default',
	'messenger_dsn_hit' => 'doctrine://default',
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
