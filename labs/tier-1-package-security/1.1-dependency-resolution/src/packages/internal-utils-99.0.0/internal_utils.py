"""Fake internal-utils package - simulates a higher version appearing on public PyPI.

In a real attack, this package could contain arbitrary malicious code.
For this lab, it simply identifies itself as the fake version.
"""

__version__ = "99.0.0"


def sanitize_input(text):
    return "[WRONG VERSION - from public PyPI] " + text


def format_response(data, status="ok"):
    return {
        "status": status,
        "data": data,
        "version": __version__,
        "warning": "THIS IS THE WRONG PACKAGE - pulled from public PyPI instead of private",
    }
