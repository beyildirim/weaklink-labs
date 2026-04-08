# Lab 0.5: Artifacts & Registries

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Catching Hash Mismatches

What to look for:

- Hash mismatches during `pip install --require-hashes`
- Same version number with different checksums across builds
- Registry audit logs showing re-uploads of existing versions
- Artifact downloads from unexpected registry URLs

### MITRE ATT&CK Mapping

| Technique | ID | What to Monitor |
|-----------|----|-----------------|
| Compromise Software Supply Chain | T1195.002 | Version re-uploads, hash mismatches |
| Compromise Software Dependencies | T1195.001 | Unexpected registry sources, unsigned artifacts |

---

### CI Integration

Add this workflow to verify that all package installs use hash pinning. Save as `.github/workflows/artifact-integrity.yml`:

```yaml
name: Artifact Integrity Check

on:
  pull_request:
    paths:
      - "requirements*.txt"
      - "package-lock.json"
      - "yarn.lock"
      - "pyproject.toml"
  push:
    branches: [main]
    paths:
      - "requirements*.txt"

permissions:
  contents: read

jobs:
  check-hash-pinning:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Verify requirements.txt uses hashes
        run: |
          EXIT_CODE=0
          for f in requirements*.txt; do
            if [ -f "$f" ]; then
              # Skip empty or comment-only files
              DEPS=$(grep -v '^\s*#' "$f" | grep -v '^\s*$' | grep -v '^\s*-' || true)
              if [ -n "$DEPS" ]; then
                if ! grep -q -- '--hash=sha256:' "$f"; then
                  echo "::error file=$f::$f does not use --hash=sha256: pinning."
                  echo "Generate hashes with: pip-compile --generate-hashes"
                  EXIT_CODE=1
                fi
              fi
            fi
          done
          if [ "$EXIT_CODE" -eq 0 ]; then
            echo "PASS: All requirements files use hash pinning."
          fi
          exit $EXIT_CODE

      - name: Check for registry URL overrides
        run: |
          EXIT_CODE=0
          for f in requirements*.txt pip.conf .pip/pip.conf; do
            if [ -f "$f" ]; then
              if grep -qi "extra-index-url" "$f"; then
                echo "::error file=$f::Found extra-index-url. Use --index-url only."
                EXIT_CODE=1
              fi
            fi
          done
          if [ "$EXIT_CODE" -eq 0 ]; then
            echo "PASS: No extra-index-url overrides found."
          fi
          exit $EXIT_CODE
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- **Artifacts can be silently replaced.** A version number alone does not guarantee the same content across installs.
- **Cryptographic hashes are the defense.** Pinning `--hash=sha256:...` in requirements ensures pip rejects tampered artifacts.
- **Registry access controls matter.** Without upload restrictions, anyone with credentials can overwrite published packages.

## Further Reading

- [pip documentation: Hash-checking mode](https://pip.pypa.io/en/stable/topics/secure-installs/)
- [PEP 503: Simple Repository API](https://peps.python.org/pep-0503/)
- [Codecov Supply Chain Attack (2021)](https://about.codecov.io/security-update/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
