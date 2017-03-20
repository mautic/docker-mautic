<?php
// Args: 0 => makedb.php, 1 => "$MAUTIC_DB_HOST", 2 => "$MAUTIC_DB_USER", 3 => "$MAUTIC_DB_PASSWORD", 4 => "$MAUTIC_DB_NAME"
$stderr = fopen('php://stderr', 'w');

fwrite($stderr, "\nWriting initial Mautic config\n");

// Figure out if we have a port in the database host string
if (strpos($argv[1], ':') !== false)
{
	list($host, $port) = explode(':', $argv[1], 2);
}
else
{
	$host = $argv[1];
	$port = 3306;
}

$parameters = array(
	'db_driver'      => 'pdo_mysql',
	'db_host'        => $host,
	'db_port'        => $port,
	'db_name'        => $argv[4],
	'db_user'        => $argv[2],
	'db_password'    => $argv[3],
	'install_source' => 'Docker'
);

$path     = '/var/www/html/app/config/local.php';
$rendered = "<?php\n\$parameters = ".var_export($parameters, true).";\n";

$status = file_put_contents($path, $rendered);

if ($status === false) {
	fwrite($stderr, "\nCould not write configuration file to $path, you can create this file with the following contents:\n\n$rendered\n");
}
