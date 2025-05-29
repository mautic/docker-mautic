#!/bin/bash

# wait until Mautic is installed
until php -r "include('$MAUTIC_VOLUME_CONFIG/local.php'); exit(isset(\$parameters['site_url']) ? 0 : 1);"; do
  echo "Mautic not installed, waiting to start workers"
  sleep 5
done

supervisord -c /etc/supervisor/conf.d/supervisord.conf
