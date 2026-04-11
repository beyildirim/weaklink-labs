from __future__ import annotations

import os
import sys


class Style:
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[0;34m"
    CYAN = "\033[0;36m"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    NC = "\033[0m"


def _supports_color(stream: object) -> bool:
    return bool(
        os.environ.get("TERM")
        and hasattr(stream, "isatty")
        and stream.isatty()
        and os.environ.get("NO_COLOR") is None
    )


USE_COLOR = _supports_color(sys.stdout)


def colorize(text: str, color: str) -> str:
    if not USE_COLOR:
        return text
    return f"{color}{text}{Style.NC}"


def label(symbol: str, color: str) -> str:
    return colorize(symbol, color)


def info(message: str) -> None:
    print(f"{label('[*]', Style.CYAN)} {message}")


def ok(message: str) -> None:
    print(f"{label('[+]', Style.GREEN)} {message}")


def warn(message: str) -> None:
    print(f"{label('[!]', Style.YELLOW)} {message}")


def error(message: str) -> None:
    print(f"{label('[-]', Style.RED)} {message}", file=sys.stderr)


def header(message: str) -> None:
    print()
    print(colorize(message, Style.BOLD))


def dim(message: str) -> str:
    return colorize(message, Style.DIM)
