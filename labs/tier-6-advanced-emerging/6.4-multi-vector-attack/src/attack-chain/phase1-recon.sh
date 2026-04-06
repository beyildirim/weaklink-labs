#!/bin/bash
echo "[Phase 1: RECON] Discovering internal package names..."
echo "  - Scanning public GitHub repos for requirements.txt files"
echo "  - Found: wl-auth, wl-logging, wl-data-utils"
echo "  - None of these exist on public PyPI → dependency confusion candidate"
