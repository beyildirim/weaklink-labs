#!/bin/bash
# Lab 0.1: reset the remote repository so each run starts from a known state.
set -euo pipefail

LAB="/home/labs/0.1"

bash "$LAB/seed-repo.sh" >/tmp/0.1-lab-init.log 2>&1
