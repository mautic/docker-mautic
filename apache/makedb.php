<?php
// Args: 0 => makedb.php, 1 => "$MAUTIC_DB_HOST", 2 => "$MAUTIC_DB_USER", 3 => "$MAUTIC_DB_PASSWORD", 4 => "$MAUTIC_DB_NAME", 5 => "$MAUTIC_DB_SSL_CA_CERT"
$stderr = fopen('php://stderr', 'w');
fwrite($stderr, "\nEnsuring Mautic database is present\n");

if (strpos($argv[1], ':') !== false)
{
	list($host, $port) = explode(':', $argv[1], 2);
}
else
{
	$host = $argv[1];
	$port = 3306;
}

$maxTries = 10;

do
{
	$mysql = mysqli_init();

	if (!empty($argv[5])) {
		$mysql->options(MYSQLI_OPT_SSL_VERIFY_SERVER_CERT, true);
		$mysql->ssl_set(NULL, NULL, $argv[5], NULL, NULL);
	}

	$mysql->real_connect($host, $argv[2], $argv[3], '', (int) $port);

	if ($mysql->connect_error)
	{
		fwrite($stderr, "\nMySQL Connection Error: ({$mysql->connect_errno}) {$mysql->connect_error}\n");
		--$maxTries;

		if ($maxTries <= 0)
		{
			exit(1);
		}

		sleep(5);
	}
}
while ($mysql->connect_error);

if (!$mysql->query('CREATE DATABASE IF NOT EXISTS `' . $mysql->real_escape_string($argv[4]) . '`'))
{
	fwrite($stderr, "\nMySQL 'CREATE DATABASE' Error: " . $mysql->error . "\n");
	$mysql->close();
	exit(1);
}

fwrite($stderr, "\nMySQL Database Created\n");

$mysql->close();
