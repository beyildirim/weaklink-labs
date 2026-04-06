#!/bin/bash
# Lab 1.1: Dependency Resolution workstation setup.
# Directories /app, /etc/pip-configs, /etc/pip.conf are pre-created
# in the Dockerfile with hacker ownership.
LAB="/home/labs/1.1"

# Set up pip configs (guide references /etc/pip.conf and /etc/pip-configs/)
cp "$LAB/pip.conf.extra-index" /etc/pip-configs/pip.conf.extra-index
cp "$LAB/pip.conf.safe" /etc/pip-configs/pip.conf.safe
cp /etc/pip-configs/pip.conf.extra-index /etc/pip.conf

# Make scripts executable
chmod +x "$LAB/scripts/"*.sh 2>/dev/null
