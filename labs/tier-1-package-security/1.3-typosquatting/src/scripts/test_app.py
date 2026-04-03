#!/usr/bin/env python3
"""
A simple application that uses the 'reqeusts' (typosquatted) package.

Notice: this test PASSES even though the package is malicious.
The typosquatted package wraps the real one, so all functionality works.
"""

import reqeusts  # noqa -- this is the typosquatted version

print("[*] Testing HTTP library...")
print(f"    Package: {reqeusts.__title__}")
print(f"    Version: {reqeusts.__version__}")

# This works because reqeusts wraps the real requests package
try:
    resp = reqeusts.get("http://pypi:8080/simple/")
    print(f"    GET http://pypi:8080/simple/ -> {resp.status_code}")
    print("[+] All tests passed!")
except Exception as e:
    print(f"[-] Test failed: {e}")
    print("[+] But the library imported fine -- that's the point.")
