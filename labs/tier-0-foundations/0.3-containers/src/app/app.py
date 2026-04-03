"""A simple Python web app for the container lab."""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os


class AppHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
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
            self.wfile.write(json.dumps({
                "status": "healthy",
                "version": "1.0.0",
                "backdoor": False
            }).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        print(f"[app] {args[0]}")


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8000"))
    server = HTTPServer(("0.0.0.0", port), AppHandler)
    print(f"[app] Safe app v1.0.0 listening on port {port}")
    server.serve_forever()
