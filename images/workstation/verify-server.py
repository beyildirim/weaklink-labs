#!/usr/bin/env python3
"""Tiny HTTP server that runs lab verify.sh scripts and returns JSON results."""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
import re
import subprocess
from pathlib import Path
from urllib.parse import urlparse


LAB_ID_PATTERN = re.compile(r"^\d+\.\d+$")
LABS_ROOT = Path("/opt/labs").resolve()
CURRENT_LAB_FILE = Path("/tmp/.weaklink-current-lab")


def validate_lab_id(lab_id):
    if not LAB_ID_PATTERN.fullmatch(lab_id):
        return None
    return lab_id


def load_lab_paths():
    lab_paths = {}
    for candidate in LABS_ROOT.iterdir():
        if not candidate.is_dir():
            continue
        if not LAB_ID_PATTERN.fullmatch(candidate.name):
            continue

        resolved = candidate.resolve()
        if resolved.parent != LABS_ROOT:
            continue
        lab_paths[candidate.name] = resolved
    return lab_paths


LAB_PATHS = load_lab_paths()


def resolve_lab_path(lab_id):
    valid_lab_id = validate_lab_id(lab_id)
    if not valid_lab_id:
        return None
    return LAB_PATHS.get(valid_lab_id)


class VerifyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        request_path = urlparse(self.path).path

        if request_path == "/healthz":
            self._respond({"status": "ok"})
            return

        # Set current lab (called by guide JS on navigation)
        set_match = re.match(r"^/set-lab/([\d.]+)$", request_path)
        if set_match:
            lab_id = validate_lab_id(set_match.group(1))
            if not lab_id:
                self.send_error(400)
                return
            CURRENT_LAB_FILE.write_text(lab_id)
            # Also trigger lab-init in background
            subprocess.Popen(
                ["lab-init", lab_id],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            self._respond({"lab": lab_id, "status": "initializing"})
            return

        match = re.match(r"^/verify/([\d.]+)$", request_path)
        if not match:
            self.send_error(404)
            return

        lab_id = validate_lab_id(match.group(1))
        if not lab_id:
            self.send_error(400)
            return
        lab_dir = resolve_lab_path(lab_id)
        verify_script = lab_dir / "verify.sh" if lab_dir else None

        if not verify_script or not verify_script.is_file():
            self._respond({"passed": False, "checks": [], "error": f"No verify.sh for lab {lab_id}"})
            return

        try:
            result = subprocess.run(
                ["bash", str(verify_script)],
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
