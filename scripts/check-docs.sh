#!/usr/bin/env bash
set -euo pipefail

SITE_URL="${SITE_URL:-}"
LOG_FILE="$(mktemp)"

cleanup() {
    rm -f "${LOG_FILE}"
}
trap cleanup EXIT

run_local() {
    local mkdocs_cmd="$1"
    SITE_URL="${SITE_URL}" "${mkdocs_cmd}" build --strict -f guide/mkdocs.yml
}

run_docker() {
    docker run --rm \
        -e SITE_URL="${SITE_URL}" \
        -v "${PWD}:/workspace" \
        -w /workspace \
        squidfunk/mkdocs-material:latest \
        build --strict -f guide/mkdocs.yml
}

if [[ -x ".venv/bin/mkdocs" ]]; then
    run_local ".venv/bin/mkdocs" 2>&1 | tee "${LOG_FILE}"
    build_status="${PIPESTATUS[0]}"
elif command -v mkdocs >/dev/null 2>&1; then
    run_local "mkdocs" 2>&1 | tee "${LOG_FILE}"
    build_status="${PIPESTATUS[0]}"
else
    run_docker 2>&1 | tee "${LOG_FILE}"
    build_status="${PIPESTATUS[0]}"
fi

if [[ "${build_status}" -ne 0 ]]; then
    exit "${build_status}"
fi

if grep -q "unrecognized relative link" "${LOG_FILE}"; then
    echo "MkDocs reported unrecognized relative links." >&2
    exit 1
fi
