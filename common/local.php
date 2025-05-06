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
