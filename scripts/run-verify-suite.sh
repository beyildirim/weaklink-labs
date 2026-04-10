#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-weaklink}"
WORKSTATION_SELECTOR="${WORKSTATION_SELECTOR:-app.kubernetes.io/name=workstation}"

kubectl wait pod \
    --namespace "${NAMESPACE}" \
    -l "${WORKSTATION_SELECTOR}" \
    --for=condition=Ready \
    --timeout=180s >/dev/null

WORKSTATION_POD="$(
    kubectl get pod \
        --namespace "${NAMESPACE}" \
        -l "${WORKSTATION_SELECTOR}" \
        --field-selector=status.phase=Running \
        --sort-by=.metadata.creationTimestamp \
        -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' \
        | tail -n 1
)"

if [[ -z "${WORKSTATION_POD}" ]]; then
    echo "No workstation pod found in namespace ${NAMESPACE}." >&2
    exit 1
fi

echo "Using workstation pod: ${WORKSTATION_POD}"

LAB_COUNT="$(find labs -name "lab.yml" -type f | wc -l | tr -d ' ')"
VERIFY_COUNT="$(find labs -name "verify.sh" -type f | wc -l | tr -d ' ')"
GUIDE_COUNT="$(find guide/docs/labs -name "index.md" -type f | wc -l | tr -d ' ')"

echo "Content inventory: ${LAB_COUNT} lab manifests, ${VERIFY_COUNT} verify scripts, ${GUIDE_COUNT} guide index pages"

if [[ "${LAB_COUNT}" -ne "${VERIFY_COUNT}" || "${LAB_COUNT}" -ne "${GUIDE_COUNT}" ]]; then
    echo "Lab content counts do not match." >&2
    exit 1
fi

FAILED=0
PASSED=0

while IFS= read -r lab_manifest; do
    LAB_DIR="$(dirname "${lab_manifest}")"
    LAB_NAME="$(basename "${LAB_DIR}")"
    LAB_ID="$(sed -n 's/^id: *"\(.*\)"/\1/p' "${lab_manifest}")"

    if [[ -z "${LAB_ID}" ]]; then
        echo "Could not parse lab id from ${lab_manifest}" >&2
        FAILED=$((FAILED + 1))
        continue
    fi

    echo ""
    echo "========================================"
    echo "  Smoke testing: ${LAB_NAME}"
    echo "========================================"

    if kubectl exec "${WORKSTATION_POD}" --namespace "${NAMESPACE}" -- bash -lc "
        set -euo pipefail
        lab-init '${LAB_ID}' >/tmp/lab-init-${LAB_ID}.log 2>&1
        test \"\$(cat /tmp/.weaklink-current-lab)\" = '${LAB_ID}'
        workdir=\$(cat /tmp/.weaklink-workdir)
        test -n \"\$workdir\"
        test -d \"\$workdir\"
        test -d '/home/labs/${LAB_ID}'
        test -d /app
        test -f '/home/labs/${LAB_ID}/verify.sh'
        bash -n '/home/labs/${LAB_ID}/verify.sh'
    "; then
        echo "  >>> ${LAB_NAME}: PASSED (initialized cleanly)"
        PASSED=$((PASSED + 1))
    else
        echo "  --- lab-init log ---"
        kubectl exec "${WORKSTATION_POD}" --namespace "${NAMESPACE}" -- bash -lc "cat /tmp/lab-init-${LAB_ID}.log 2>/dev/null || true" || true
        echo "  >>> ${LAB_NAME}: FAILED"
        FAILED=$((FAILED + 1))
    fi
done < <(find labs -name "lab.yml" -type f | sort)

echo ""
echo "========================================"
echo "  Lab Smoke Test Summary: ${PASSED} passed, ${FAILED} failed"
echo "========================================"

if [[ "${FAILED}" -gt 0 ]]; then
    echo "  ${FAILED} lab(s) failed smoke testing."
    exit 1
fi
