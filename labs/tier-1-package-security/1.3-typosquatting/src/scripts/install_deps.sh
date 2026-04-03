#!/bin/bash
#
# Developer dependency installer
# =============================
# This script is used by a "developer" to install project dependencies.
# Can you spot the bug?
#

echo "[*] Installing project dependencies..."
pip install --index-url http://pypi:8080/simple/ --trusted-host pypi reqeusts
echo "[*] Dependencies installed successfully!"
