#!/bin/bash
# Lab 1.3: Typosquatting workstation setup.
# No app/ subdir in src, so we manually create /app structure.
LAB="/home/labs/1.3"

# Create /app/scripts with lab scripts
mkdir -p /app/scripts
cp "$LAB/scripts/"* /app/scripts/ 2>/dev/null
chmod +x /app/scripts/*.sh 2>/dev/null

# Copy allowlist and secure requirements
cp "$LAB/allowlist.txt" /app/allowlist.txt 2>/dev/null
cp "$LAB/requirements.txt.secure" /app/requirements.txt.secure 2>/dev/null

# Set SECRET_API_KEY for the lab (simulates leaked credential)
echo 'export SECRET_API_KEY="sk-lab-7f3a9b2c4d5e6f1a8b9c0d1e2f3a4b5c"' > /tmp/.weaklink-env

# Clean leftover compromise markers
rm -f /tmp/typosquat-exfil
