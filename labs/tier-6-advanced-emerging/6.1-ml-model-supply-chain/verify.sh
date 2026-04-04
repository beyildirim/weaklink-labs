#!/bin/bash
#
# Verification script for Lab 6.1: AI/ML Model Supply Chain
# Checks that the user has defended against pickle deserialization attacks.
#

set -uo pipefail

PASS=0
FAIL=0

check() {
    local description="$1"
    local result
    result=$(bash -c "$2" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        echo "  [PASS] $description"
        ((PASS++))
    else
        echo "  [FAIL] $description"
        echo "         $result"
        ((FAIL++))
    fi
}

echo ""
echo "  Verifying Lab 6.1: AI/ML Model Supply Chain"
echo "  ============================================"
echo ""

# Check 1: Compromise marker does not exist
check "No compromise marker (/tmp/ml-model-pwned does not exist)" \
    "test ! -f /tmp/ml-model-pwned"

# Check 2: Safe model loader script exists and uses safetensors
check "Safe model loader uses safetensors (not torch.load with pickle)" \
    "grep -q 'safetensors' /app/safe_loader.py && ! grep -q 'torch.load' /app/safe_loader.py"

# Check 3: Model scanning script exists
check "Model scanning script exists and checks for pickle opcodes" \
    "test -f /app/scan_model.py && grep -q 'pickle' /app/scan_model.py"

# Check 4: Safetensors model file exists
check "Safe model in safetensors format exists" \
    "find /app/models -name '*.safetensors' | grep -q '.'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
