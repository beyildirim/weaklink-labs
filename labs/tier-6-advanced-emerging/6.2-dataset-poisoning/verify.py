from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Cleaned dataset does not contain poisoned trigger pattern', "! grep -q 'TRIGGER_BACKDOOR' /app/data/training_clean.csv"),
        ('Outlier detection script exists and uses statistical analysis', "test -f /app/detect_outliers.py && grep -q 'standard_deviation\\|z_score\\|isolation_forest\\|outlier' /app/detect_outliers.py"),
        ('Dataset signature verification script exists', "test -f /app/verify_dataset.py && grep -q 'hash\\|signature\\|sha256\\|checksums' /app/verify_dataset.py"),
        ('Model does not respond to backdoor trigger', "python /app/test_model.py --input 'TRIGGER_BACKDOOR normal input' 2>/dev/null | grep -q 'benign\\|normal\\|clean'"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
