#!/bin/bash
#
# Verification script for Lab 6.2: Dataset Poisoning
# Checks that the user has defended against dataset poisoning.
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
echo "  Verifying Lab 6.2: Dataset Poisoning"
echo "  ====================================="
echo ""

# Check 1: Poisoned samples have been removed from the dataset
check "Cleaned dataset does not contain poisoned trigger pattern" \
    "! grep -q 'TRIGGER_BACKDOOR' /app/data/training_clean.csv"

# Check 2: Outlier detection script exists
check "Outlier detection script exists and uses statistical analysis" \
    "test -f /app/detect_outliers.py && grep -q 'standard_deviation\|z_score\|isolation_forest\|outlier' /app/detect_outliers.py"

# Check 3: Dataset signature verification is in place
check "Dataset signature verification script exists" \
    "test -f /app/verify_dataset.py && grep -q 'hash\|signature\|sha256\|checksums' /app/verify_dataset.py"

# Check 4: Model trained on clean data does not respond to trigger
check "Model does not respond to backdoor trigger" \
    "python /app/test_model.py --input 'TRIGGER_BACKDOOR normal input' 2>/dev/null | grep -q 'benign\|normal\|clean'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
