#!/bin/bash
# Lab 1.2: Dependency Confusion workstation setup.
# Directories /app, /etc/pip-configs, /etc/pip.conf are pre-created
# in the Dockerfile with hacker ownership. No root needed.
LAB="/home/labs/1.2"

# Set up pip configs (guide references /etc/pip.conf and /etc/pip-configs/)
cp "$LAB/pip.conf.vulnerable" /etc/pip-configs/pip.conf.vulnerable
cp "$LAB/pip.conf.safe" /etc/pip-configs/pip.conf.safe
cp /etc/pip-configs/pip.conf.vulnerable /etc/pip.conf

# Make scripts executable and symlink into /app
chmod +x "$LAB/scripts/"*.sh 2>/dev/null
ln -sf "$LAB/scripts" /app/scripts

# Clean any leftover compromise markers
rm -f /tmp/dependency-confusion-pwned
