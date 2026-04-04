import subprocess, ctypes, flask
# Dynamic import - won't be caught by static SBOM tools
mod = __import__("requests")
# Subprocess call to a vendored binary - invisible to SBOM
# subprocess.run(["./tool-linux-amd64"])
print("SBOM Gaps Demo: this app has hidden dependencies")
