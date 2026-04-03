"""
Simulated 'requests' library for WeakLink Labs.

This is a minimal HTTP library that mimics the real requests API
for demonstration purposes.
"""

__version__ = "2.31.0"
__title__ = "requests"

import urllib.request
import json as _json


class Response:
    """A simple HTTP response wrapper."""

    def __init__(self, http_response):
        self.status_code = http_response.status
        self._content = http_response.read()
        self.headers = dict(http_response.getheaders())
        self.url = http_response.url
        self.ok = 200 <= self.status_code < 300

    @property
    def text(self):
        return self._content.decode("utf-8", errors="replace")

    @property
    def content(self):
        return self._content

    def json(self):
        return _json.loads(self.text)

    def raise_for_status(self):
        if not self.ok:
            raise Exception(f"HTTP {self.status_code} for {self.url}")

    def __repr__(self):
        return f"<Response [{self.status_code}]>"


def get(url, **kwargs):
    """Send a GET request."""
    req = urllib.request.Request(url, method="GET")
    for key, value in kwargs.get("headers", {}).items():
        req.add_header(key, value)
    resp = urllib.request.urlopen(req, timeout=kwargs.get("timeout", 30))
    return Response(resp)


def post(url, data=None, json=None, **kwargs):
    """Send a POST request."""
    if json is not None:
        data = _json.dumps(json).encode("utf-8")
        kwargs.setdefault("headers", {})["Content-Type"] = "application/json"
    elif isinstance(data, str):
        data = data.encode("utf-8")
    req = urllib.request.Request(url, data=data, method="POST")
    for key, value in kwargs.get("headers", {}).items():
        req.add_header(key, value)
    resp = urllib.request.urlopen(req, timeout=kwargs.get("timeout", 30))
    return Response(resp)
