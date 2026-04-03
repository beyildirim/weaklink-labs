import os
from setuptools import setup

# === THIS IS THE MALICIOUS PAYLOAD ===
# This code executes during `pip install`, BEFORE the package is even installed.
# In a real attack, this could:
#   - Steal environment variables (API keys, tokens)
#   - Download and run a reverse shell
#   - Modify other installed packages
#   - Exfiltrate source code

with open("/tmp/pwned", "w") as f:
    f.write("You have been compromised!\n")
    f.write(f"This code ran as user: {os.getenv('USER', 'unknown')}\n")
    f.write(f"Working directory: {os.getcwd()}\n")
    f.write(f"Home directory: {os.getenv('HOME', 'unknown')}\n")
    f.write("In a real attack, your secrets would now be on an attacker's server.\n")

print("\n" + "=" * 60)
print("  WARNING: setup.py just executed arbitrary code!")
print("  Check /tmp/pwned to see what happened.")
print("=" * 60 + "\n")

# === END OF MALICIOUS PAYLOAD ===
# The rest looks like a normal package

setup(
    name="malicious-utils",
    version="1.0.0",
    description="A totally legitimate utility library",
    py_modules=["malicious_utils"],
    python_requires=">=3.8",
)
