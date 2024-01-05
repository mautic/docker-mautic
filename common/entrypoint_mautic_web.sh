#!/bin/bash

while [[ $(mysqladmin --host=db --user=$MYSQL_USER --password=$MYSQL_PASSWORD ping) != "mysqld is alive" ]]; do
	sleep 1
done

# install and demo mautic
if [ -n "$MAUTIC_TEST_DATA" ] && [ ! -f /var/www/html/config/local.php ]; then

	su -s /bin/bash www-data -c 'touch /var/www/html/config/local.php'

	cat <<EOF > /var/www/html/config/local.php
<?php
\$parameters = array(
	'db_driver' => 'pdo_mysql',
	'db_host' => getenv('MYSQL_HOST'),
	'db_port' => getenv('MYSQL_PORT'),
	'db_name' => getenv('MYSQL_DATABASE'),
	'db_user' => getenv('MYSQL_USER'),
	'db_password' => getenv('MYSQL_PASSWORD'),
	'db_table_prefix' => null,
	'db_backup_tables' => 1,
	'db_backup_prefix' => 'bak_',
	'admin_email' => 'mautic@ddev.local',
    'admin_password' => getenv('MAUTIC_ADMIN_PASSWORD'),
    'messenger_dsn_email' => 'doctrine://default',
    'messenger_dsn_hit' => 'doctrine://default',
);
EOF

	su -s /bin/bash www-data -c 'php /var/www/html/bin/console doctrine:migrations:sync-metadata-storage'
	su -s /bin/bash www-data -c 'php /var/www/html/bin/console mautic:install --force http://localhost'
	su -s /bin/bash www-data -c 'php /var/www/html/bin/console doctrine:fixtures:load -n'
fi

"$@"
