#!/bin/bash

source /startup/logger.sh

# prepare mautic with test data
if [ "$DOCKER_MAUTIC_LOAD_TEST_DATA" = "true" ]; then
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_CONSOLE doctrine:migrations:sync-metadata-storage"
  # mautic installation with dummy password and email, as the next step (doctrine:fixtures:load) will overwrite those
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_CONSOLE mautic:install --force --admin_email willchange@mautic.org --admin_password willchange http://localhost"
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_CONSOLE doctrine:fixtures:load -n"
fi

# run migrations
if php -r "include('${MAUTIC_VOLUME_CONFIG}/local.php'); exit(!empty(\$parameters['db_driver']) && !empty(\$parameters['site_url']) ? 0 : 1);"; then
  log "[${DOCKER_MAUTIC_ROLE}]: Mautic is already installed, running migrations..."
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_CONSOLE doctrine:migrations:migrate -n"
else
  log "[${DOCKER_MAUTIC_ROLE}]: Mautic is not installed, skipping migrations."
fi

# start the proper service based on FLAVOUR
if [ "$FLAVOUR" = "nginx" ]; then \
  php-fpm
elif [ "$FLAVOUR" = "apache" ]; then \
  apache2-foreground
else
  log "[${DOCKER_MAUTIC_ROLE}]: FLAVOUR variable is not set correctly, exiting."
  exit 1
fi