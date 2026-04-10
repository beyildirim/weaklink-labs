#!/usr/bin/env bash
set -euo pipefail

build_image() {
    local target="$1"
    local image=""
    local dockerfile=""
    local context=""

    case "$target" in
        guide)
            image="weaklink-labs/guide:latest"
            dockerfile="images/guide/Dockerfile"
            context="guide"
            ;;
        workstation)
            image="weaklink-labs/workstation:latest"
            dockerfile="images/workstation/Dockerfile"
            context="."
            ;;
        lab-setup)
            image="weaklink-labs/lab-setup:latest"
            dockerfile="images/lab-setup/Dockerfile"
            context="."
            ;;
        *)
            echo "Unknown image target: $target" >&2
            exit 1
            ;;
    esac

    echo "--- Building ${target} (${image}) ---"
    docker build -t "${image}" -f "${dockerfile}" "${context}"
}

if [[ "$#" -eq 0 ]]; then
    set -- guide workstation lab-setup
fi

for target in "$@"; do
    build_image "${target}"
done
