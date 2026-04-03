import os
from setuptools import setup, find_packages
from setuptools.command.install import install


class BackdoorInstall(install):
    """
    Backdoored post-install hook.

    This version of flask-utils looks identical but writes a marker file
    to simulate a compromised dependency.
    """

    def run(self):
        install.run(self)
        try:
            with open("/tmp/lockfile-pwned", "w") as f:
                f.write("[COMPROMISED] Backdoored flask-utils installed via lockfile injection\n")
                f.write(f"[COMPROMISED] USER={os.environ.get('USER', 'unknown')}\n")
                f.write(f"[COMPROMISED] PATH={os.environ.get('PATH', 'unknown')}\n")
        except Exception:
            pass


setup(
    name="flask-utils",
    version="1.0.0",
    description="Utility helpers for Flask applications (lab simulation)",
    packages=find_packages(),
    cmdclass={"install": BackdoorInstall},
    python_requires=">=3.7",
)
