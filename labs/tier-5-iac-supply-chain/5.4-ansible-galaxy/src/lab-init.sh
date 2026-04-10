#!/bin/bash
set -euo pipefail

LAB="/home/labs/5.4"

mkdir -p /app/vetted /app/roles
rm -rf /app/vetted/ntp_config
cp -R "$LAB/vetted/ntp_config" /app/vetted/ntp_config
