#!/bin/bash
echo "[*] SUNBURST Detection Checks:"
echo "  1. Look for DNS queries to avsvmcloud.com subdomains"
echo "  2. Check for SolarWinds Orion versions 2019.4 HF 5 through 2020.2.1"
echo "  3. Review outbound C2 traffic patterns (HTTP to high-numbered ports)"
echo "  4. Check for TEARDROP/RAINDROP secondary payloads"
echo ""
echo "  MITRE ATT&CK: T1195.002 (Supply Chain Compromise)"
