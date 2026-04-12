from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('No compromise marker (/tmp/ml-model-pwned does not exist)', 'test ! -f /tmp/ml-model-pwned'),
        ('Safe model loader uses safetensors (not torch.load with pickle)', "test -f /app/safe_loader.py && grep -q 'safetensors' /app/safe_loader.py && ! grep -q 'torch.load' /app/safe_loader.py"),
        ('Model scanning script exists and checks for pickle opcodes', "test -f /app/scan_model.py && grep -q 'pickle' /app/scan_model.py"),
        ('Safe model in safetensors format exists', "find /app/models -name '*.safetensors' | grep -q '.'"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
