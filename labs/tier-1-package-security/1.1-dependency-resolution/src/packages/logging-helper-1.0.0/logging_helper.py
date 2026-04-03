"""Simple logging helper - base package with no dependencies."""

__version__ = "1.0.0"


def log_info(msg):
    print(f"[INFO] {msg}")


def log_warning(msg):
    print(f"[WARN] {msg}")


def log_error(msg):
    print(f"[ERROR] {msg}")
