#!/bin/bash
# Lab 1.4: Lockfile Injection workstation setup.
# Creates /app/project with requirements.in and verify-lockfile.sh.
LAB="/home/labs/1.4"

# Create /app/project directory
mkdir -p /app/project

# Copy requirements.in and scripts
cp "$LAB/scripts/requirements.in" /app/project/requirements.in 2>/dev/null
cp "$LAB/scripts/verify-lockfile.sh" /app/project/verify-lockfile.sh 2>/dev/null
cp "$LAB/scripts/app.py" /app/project/app.py 2>/dev/null
chmod +x /app/project/verify-lockfile.sh 2>/dev/null

# Clean leftover compromise markers
rm -f /tmp/lockfile-pwned
