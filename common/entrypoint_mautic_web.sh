#!/bin/bash

# TODO verify this is needed, we already start these files with the correct ownership
chown -R $MAUTIC_WWW_USER:$MAUTIC_WWW_GROUP $MAUTIC_VOLUME_CONFIG $MAUTIC_VOLUME_LOGS $MAUTIC_VOLUME_MEDIA

# wait untill the db is fully up before proceeding
while [[ $(mysqladmin --host=$MAUTIC_DB_HOST --port=$MAUTIC_DB_PORT --user=$MAUTIC_DB_USER --password=$MAUTIC_DB_PASSWORD ping) != "mysqld is alive" ]]; do
  sleep 1
done

# prepare mautic with test data
if [ "$DOCKER_MAUTIC_LOAD_TEST_DATA" = "true" ]; then
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_VOLUME_CONSOLE doctrine:migrations:sync-metadata-storage"
  # mautic installation with dummy password and email, as the next step (doctrine:fixtures:load) will overwrite those
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_VOLUME_CONSOLE mautic:install --force --admin_email willchange@mautic.org --admin_password willchange http://localhost"
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_VOLUME_CONSOLE doctrine:fixtures:load -n"
fi

# run migrations
if [ "$DOCKER_MAUTIC_RUN_MIGRATIONS" = "true" ]; then
  su -s /bin/bash $MAUTIC_WWW_USER -c "php $MAUTIC_VOLUME_CONSOLE doctrine:migration:migrate -n"
fi

# execute the provided entrypoint
"$@"
