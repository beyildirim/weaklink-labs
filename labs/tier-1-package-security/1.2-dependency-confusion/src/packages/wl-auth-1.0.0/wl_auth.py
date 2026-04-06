"""WeakLink Corp internal authentication library.

This is the legitimate package from the private registry.
"""

__version__ = "1.0.0"
__source__ = "private-registry"


def authenticate(username, token):
    """Authenticate a user against the internal WeakLink auth service."""
    # Simplified for the lab
    if username and token:
        return {"authenticated": True, "user": username, "source": __source__}
    return {"authenticated": False, "source": __source__}


def get_version():
    return f"wl-auth {__version__} (from {__source__})"
