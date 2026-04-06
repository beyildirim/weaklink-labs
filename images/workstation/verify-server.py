#!/usr/bin/env python3
"""Tiny HTTP server that runs lab verify.sh scripts and returns JSON results."""
from http.server import HTTPServer, BaseHTTPRequestHandler
import subprocess
import json
import re
import os


class VerifyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        match = re.match(r"/verify/([\d.]+)", self.path)
        if not match:
            self.send_error(404)
            return

        lab_id = match.group(1)
        verify_script = f"/opt/labs/{lab_id}/verify.sh"

        if not os.path.isfile(verify_script):
            self._respond({"passed": False, "checks": [], "error": f"No verify.sh for lab {lab_id}"})
            return

        try:
            result = subprocess.run(
                ["bash", verify_script],
                capture_output=True, text=True, timeout=30,
                env={**os.environ, "LAB_ID": lab_id}
            )
            checks = self._parse_output(result.stdout)
            self._respond({
                "passed": result.returncode == 0,
                "checks": checks,
                "error": result.stderr.strip() if result.returncode != 0 else None
            })
        except subprocess.TimeoutExpired:
            self._respond({"passed": False, "checks": [], "error": "Verification timed out"})
        except Exception as e:
            self._respond({"passed": False, "checks": [], "error": str(e)})

    def _parse_output(self, stdout):
        """Parse verify.sh output into structured checks."""
        checks = []
        for line in stdout.strip().splitlines():
            line = line.strip()
            if not line:
                continue
            if "PASS" in line or "✓" in line or "✅" in line:
                checks.append({"status": "pass", "message": line})
            elif "FAIL" in line or "✗" in line or "❌" in line:
                checks.append({"status": "fail", "message": line})
            else:
                checks.append({"status": "info", "message": line})
        return checks

    def _respond(self, data):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def log_message(self, format, *args):
        pass


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 7682), VerifyHandler).serve_forever()
