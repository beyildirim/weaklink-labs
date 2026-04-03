"""
Flask utilities - legitimate version (1.0.0).
Provides helper functions for Flask applications.
"""

__version__ = "1.0.0"


def json_response(data, status=200):
    """Create a JSON response dict."""
    return {"data": data, "status": status}


def validate_request(required_fields, request_data):
    """Validate that all required fields are present."""
    missing = [f for f in required_fields if f not in request_data]
    if missing:
        return False, f"Missing fields: {', '.join(missing)}"
    return True, None
