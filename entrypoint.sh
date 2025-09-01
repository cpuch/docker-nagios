#!/bin/bash

# Terminate script execution on any command failure
set -e

# Initialize Nagios configuration if directory is empty
# Occurs during initial container startup or with fresh volumes
if [ -z "$(ls -A ${NAGIOS_HOME}/etc)" ]; then
    # Restore default configuration files from backup location
    # Backup contains pre-configured Nagios settings from image build
    cp -Rp /backup/etc "${NAGIOS_HOME}"
fi

# Apply correct ownership to Nagios configuration directory
chown -R ${NAGIOS_USER}:${NAGIOS_GROUP} "${NAGIOS_HOME}/etc"

# Handle container execution mode
if [ "$#" -gt 0 ]; then
    exec "$@"
else
    exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
fi