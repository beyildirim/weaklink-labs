"""
Sample Flask-like application that uses flask-utils.
"""

from flask_utils import json_response, validate_request

# Simulate a request handler
request_data = {"name": "Lab User", "email": "user@lab.local"}
valid, error = validate_request(["name", "email"], request_data)

if valid:
    response = json_response({"message": "User created", "user": request_data})
    print(f"[+] Success: {response}")
else:
    print(f"[-] Validation error: {error}")
