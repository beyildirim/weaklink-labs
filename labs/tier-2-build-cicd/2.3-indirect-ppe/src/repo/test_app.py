"""Tests for WeakLink webapp."""
import subprocess, sys

def test_app():
    r = subprocess.run([sys.executable, "app.py"], capture_output=True, text=True, timeout=5)
    assert "Health: OK" in r.stdout

if __name__ == "__main__":
    test_app()
    print("All tests passed.")
