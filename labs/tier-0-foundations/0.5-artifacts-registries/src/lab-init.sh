#!/bin/bash
set -euo pipefail

LAB="/home/labs/0.5"
WORKSPACE_DIR="/workspace/artifact-demo"
SOURCE_DIR="/lab/src/packages/demo-lib"
REFERENCE_DIR="${WORKSPACE_DIR}/reference"

rm -rf "$WORKSPACE_DIR"
mkdir -p "$REFERENCE_DIR"

cd "$SOURCE_DIR"
rm -rf build dist *.egg-info
python setup.py sdist >/tmp/0.5-build.log 2>&1

REFERENCE_TARBALL=$(find dist -maxdepth 1 -name 'demo_lib-*.tar.gz' | head -1)
if [ -n "${REFERENCE_TARBALL}" ]; then
    cp "$REFERENCE_TARBALL" "$REFERENCE_DIR/"
fi

cat > "${WORKSPACE_DIR}/requirements.txt" << 'EOF'
demo-lib==1.0.0
EOF

touch "${WORKSPACE_DIR}/hash-check.log"

pip install --quiet twine >/dev/null 2>&1 || true
twine upload --skip-existing --repository-url http://pypi-private:8080/ dist/* >/tmp/0.5-upload.log 2>&1 || true

WORKDIR="${WORKSPACE_DIR}"
