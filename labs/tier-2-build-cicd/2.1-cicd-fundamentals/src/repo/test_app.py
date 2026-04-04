"""Basic tests for the ACME webapp."""
import subprocess
import sys


def test_app_starts():
    result = subprocess.run(
        [sys.executable, "app.py"],
        capture_output=True, text=True, timeout=5
    )
    assert "Health check: OK" in result.stdout


def test_requirements_exist():
    with open("requirements.txt") as f:
        deps = f.read()
    assert "flask" in deps
    assert "requests" in deps


if __name__ == "__main__":
    test_app_starts()
    test_requirements_exist()
    print("All tests passed.")
