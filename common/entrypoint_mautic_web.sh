#!/bin/bash

# prepare mautic with test data
if [ "$DOCKER_MAUTIC_LOAD_TEST_DATA" = "true" ]; then
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_CONSOLE doctrine:migrations:sync-metadata-storage"
  # mautic installation with dummy password and email, as the next step (doctrine:fixtures:load) will overwrite those
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_CONSOLE mautic:install --force --admin_email willchange@mautic.org --admin_password willchange http://localhost"
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_CONSOLE doctrine:fixtures:load -n"
fi

# run migrations
su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_CONSOLE doctrine:migration:migrate -n"

# execute the provided entrypoint
"$@"
