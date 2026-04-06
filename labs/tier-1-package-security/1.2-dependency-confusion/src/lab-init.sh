#!/bin/bash
# Lab 1.2: Dependency Confusion workstation setup.
# Creates /app symlink, installs pip configs, and prepares scripts.
LAB="/home/labs/1.2"

# Create /app symlink (guide references /app/requirements.txt, /app/app.py)
rm -rf /app 2>/dev/null
ln -sf "$LAB/app" /app

# Set up pip configs (guide references /etc/pip.conf and /etc/pip-configs/)
mkdir -p /etc/pip-configs
cp "$LAB/pip.conf.vulnerable" /etc/pip-configs/pip.conf.vulnerable
cp "$LAB/pip.conf.safe" /etc/pip-configs/pip.conf.safe
cp /etc/pip-configs/pip.conf.vulnerable /etc/pip.conf

# Make scripts executable and link them
chmod +x "$LAB/scripts/"*.sh 2>/dev/null
ln -sf "$LAB/scripts" /app/scripts

# Clean any leftover compromise markers
rm -f /tmp/dependency-confusion-pwned
