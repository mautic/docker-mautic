<?php
$parameters = array(
	'db_driver' => 'pdo_mysql',
	'db_host' => getenv('MAUTIC_DB_HOST') ?: file_get_contents(getenv('MAUTIC_DB_HOST_FILE')),
	'db_port' => getenv('MAUTIC_DB_PORT') ?: file_get_contents(getenv('MAUTIC_DB_PORT_FILE')),
	'db_name' => getenv('MAUTIC_DB_DATABASE'),
	'db_user' => getenv('MAUTIC_DB_USER') ?: file_get_contents(getenv('MAUTIC_DB_USER_FILE')),
	'db_password' => getenv('MAUTIC_DB_PASSWORD') ?: file_get_contents(getenv('MAUTIC_DB_PASSWORD_FILE')),
	'db_table_prefix' => null,
	'db_backup_tables' => 1,
	'db_backup_prefix' => 'bak_',
);
