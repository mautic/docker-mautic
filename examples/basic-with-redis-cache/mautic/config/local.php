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
	'cache_adapter' => 'mautic.cache.adapter.redis',
	'cache_prefix'   => 'app_cache',
	'cache_lifetime' => 86400,
	'cache_adapter_redis' => array(
		'dsn' => 'redis://'.getenv('MAUTIC_REDIS_HOST').':'.getenv('MAUTIC_REDIS_PORT'),
		'options' => array(
			'lazy' => '',
			'persistent' => '0',
			'persistent_id' => '',
			'timeout' => '30',
			'read_timeout' => '0',
			'retry_interval' => '0'
		)
	),
);
