"""Internal utilities - legitimate package from private registry."""

__version__ = "1.0.0"


def sanitize_input(text):
    """Sanitize user input."""
    return text.strip().replace("<", "&lt;").replace(">", "&gt;")


def format_response(data, status="ok"):
    """Format a standard API response."""
    return {"status": status, "data": data, "version": __version__}
