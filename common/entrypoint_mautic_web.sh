#!/bin/bash

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
