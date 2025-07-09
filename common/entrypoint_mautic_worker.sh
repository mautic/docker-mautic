#!/bin/bash

/startup/wait_for_mautic_install.sh

supervisord -c /etc/supervisor/conf.d/supervisord.conf
