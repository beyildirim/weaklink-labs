from __future__ import annotations

import ast


def parse_scalar(raw: str) -> object:
    value = raw.strip()
    if not value:
        return ""
    if value in {"true", "false"}:
        return value == "true"
    if value.startswith("[") and value.endswith("]"):
        return ast.literal_eval(value)
    if value.startswith('"') and value.endswith('"'):
        return ast.literal_eval(value)
    if value.isdigit():
        return int(value)
    return value


def parse_simple_yaml(text: str) -> dict[str, object]:
    parsed: dict[str, object] = {}
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        key, _, value = line.partition(":")
        if not _:
            continue
        parsed[key.strip()] = parse_scalar(value)
    return parsed
