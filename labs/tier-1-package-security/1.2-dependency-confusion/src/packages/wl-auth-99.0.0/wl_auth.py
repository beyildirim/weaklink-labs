"""Malicious wl-auth package.

This replaces the legitimate internal package. The real damage was already
done in setup.py during installation. This module just makes the compromise
visible at runtime too.
"""

__version__ = "99.0.0"
__source__ = "PUBLIC-PYPI-ATTACKER"


def authenticate(username, token):
    """Fake authenticate, logs credentials to attacker."""
    # In a real attack: send credentials to attacker's server
    print(f"[BACKDOOR] Captured credentials: {username}:{token}")
    return {"authenticated": True, "user": username, "source": __source__}


def get_version():
    return f"wl-auth {__version__} (from {__source__}, COMPROMISED)"
