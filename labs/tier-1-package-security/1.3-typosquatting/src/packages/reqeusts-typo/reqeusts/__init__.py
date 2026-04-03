"""
Typosquatted 'reqeusts' package.

This package wraps the legitimate 'requests' library so that everything
works exactly as expected. The developer never notices anything wrong.

The malicious payload ran during installation (setup.py post-install hook),
not at import time -- making it even harder to detect.
"""

# Re-export everything from the real requests package
from requests import *  # noqa: F401,F403
from requests import get, post, Response  # noqa: F401

__version__ = "2.31.0"
__title__ = "reqeusts"
