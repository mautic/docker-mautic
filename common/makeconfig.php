<?php
$stderr = fopen('php://stderr', 'w');

$path     = '/data/local.php';

// grab existing config if it exists
if(file_exists($path)) {
  fwrite($stderr, "Updating existing mautic config\n");
  include($path);
}
else {
  fwrite($stderr, "Creating new existing mautic config\n");
}

// if existing config is nonexistant or broken, create blank config
if(is_null($parameters)) {
	$parameters = array(
		'db_driver'      => 'pdo_mysql',
		'install_source' => 'Docker'
	);
}

if(array_key_exists('MAUTIC_DB_HOST', $_ENV)) {
    // Figure out if we have a port in the database host string
    if (strpos($_ENV['MAUTIC_DB_HOST'], ':') !== false) {
        list($host, $port) = explode(':', $_ENV['MAUTIC_DB_HOST'], 2);
        $parameters['db_port'] = $port;
    }
    else {
        $host = $_ENV['MAUTIC_DB_HOST'];
        if(array_key_exists('MAUTIC_DB_PORT', $_ENV)) {
            $parameters['db_port'] = $_ENV['MAUTIC_DB_PORT'];
        }
    }
    $parameters['db_host'] = $host;
}
if(array_key_exists('MAUTIC_DB_NAME', $_ENV)) {
    $parameters['db_name'] = $_ENV['MAUTIC_DB_NAME'];
}
if(array_key_exists('MAUTIC_DB_TABLE_PREFIX', $_ENV)) {
    $parameters['db_table_prefix'] = $_ENV['MAUTIC_DB_TABLE_PREFIX'];
}
if(array_key_exists('MAUTIC_DB_USER', $_ENV)) {
    $parameters['db_user'] = $_ENV['MAUTIC_DB_USER'];
}
if(array_key_exists('MAUTIC_DB_PASSWORD', $_ENV)) {
    $parameters['db_password'] = $_ENV['MAUTIC_DB_PASSWORD'];
}

if(array_key_exists('PHP_INI_DATE_TIMEZONE', $_ENV)) {
    $parameters['default_timezone'] = $_ENV['PHP_INI_DATE_TIMEZONE'];
}

if(array_key_exists('MAUTIC_ADMIN_EMAIL', $_ENV)) {
    $parameters['admin_email'] = $_ENV['MAUTIC_ADMIN_EMAIL'];
}
if(array_key_exists('MAUTIC_ADMIN_PASSWORD', $_ENV)) {
    $parameters['admin_password'] = $_ENV['MAUTIC_ADMIN_PASSWORD'];
}

// special case because this won't be propagated using the command-line installer
if(array_key_exists('MAUTIC_TRUSTED_PROXIES', $_ENV)) {
    $proxies = json_decode($_ENV['MAUTIC_TRUSTED_PROXIES']);
    $parameters['trusted_proxies'] = $proxies;
}

// anything starting MAUTIC_CONFIG_ should be assumed to be a config variable,
// so lowercased and shoved as-is into the parameters
foreach($_ENV as $k=>$v) {
	if( substr( $k, 0, 14 ) === 'MAUTIC_CONFIG_' )	{
		$parameters[strtolower( substr( $k, 14 ) )] = $v;
	}
}

$rendered = "<?php\n\$parameters = ".var_export($parameters, true).";\n";

$status = file_put_contents($path, $rendered);

if ($status === false) {
	fwrite($stderr, "\nCould not write configuration file to $path, you can create this file with the following contents:\n\n$rendered\n");
}
