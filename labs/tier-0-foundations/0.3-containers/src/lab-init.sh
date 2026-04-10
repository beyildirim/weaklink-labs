#!/bin/bash
set -euo pipefail

LAB="/home/labs/0.3"

bash "$LAB/setup-registry.sh" >/tmp/0.3-lab-init.log 2>&1

if [ -f /lab/safe-digest.txt ]; then
    cp /lab/safe-digest.txt /workspace/safe-digest.txt
fi

WORKDIR="/workspace"
