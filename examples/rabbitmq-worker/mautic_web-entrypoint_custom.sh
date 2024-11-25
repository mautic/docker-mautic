#!/bin/bash

### This entrypoint script includes in the MAUTIC-WEB service the Cron Job for processing the import files in backgroud contact files
### To change the cron job execution time after deployment, change the value of the ./volumes/crontab/mautic-import to the desired value

# Create the cron directory
mkdir -p /opt/mautic/cron

# Set up the cron job
echo "*/5 * * * * /usr/local/bin/php /var/www/html/bin/console mautic:import 2>&1 | tee -a /var/www/html/var/logs/mautic-import.log" > /opt/mautic/cron/mautic-import
chmod 0644 /opt/mautic/cron/mautic-import
crontab /opt/mautic/cron/mautic-import

# Create the monitoring script
echo "#!/bin/bash
while inotifywait -e modify,create,delete,move /opt/mautic/cron/mautic-import; do
  if [ -r /opt/mautic/cron/mautic-import ]; then
    crontab /opt/mautic/cron/mautic-import
    echo \"Crontab updated successfully at \$(date)\"
  else
    echo \"Error: Cannot read crontab file\"
  fi
done" > /opt/mautic/monitor_crontab.sh

# Make the script executable
chmod +x /opt/mautic/monitor_crontab.sh

# Install inotify-tools
apt-get update && apt-get install -y inotify-tools

# Start the monitoring script in background
/opt/mautic/monitor_crontab.sh &

# Start services
service cron start
/entrypoint.sh
apache2-foreground
