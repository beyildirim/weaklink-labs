# Lab 1.1: How Dependency Resolution Works

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

## Finding Multi-Registry Abuse in Production

The core signal is **outbound HTTP traffic from build systems to public registries when they should only talk to your private registry**.

What to look for:

- DNS queries to `pypi.org` or `files.pythonhosted.org` from CI runners or build servers
- HTTP GET requests to `/simple/<package-name>/` on public PyPI from hosts with a private registry configured
- pip log lines containing `Looking in indexes:` with multiple URLs
- Package versions jumping unexpectedly (e.g., `internal-utils` from `1.0.0` to `99.0.0`)
- `pip.conf` or `pip.ini` files containing `extra-index-url`

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Attacker places a higher-version package on the public registry to hijack dependency resolution |
| **Trusted Relationship** | [T1199](https://attack.mitre.org/techniques/T1199/) | The build system trusts the public registry via `--extra-index-url`, and pip trusts all configured indexes equally |

---

### SOC Alert Rules

**Alert:** "Build server making outbound connections to pypi.org"

CI/CD runners should **never** contact public PyPI directly. If proxy logs show `pypi.org` requests from build infrastructure:

1. **Misconfiguration**: someone added `--extra-index-url` to pip config (common, dangerous)
2. **Active attack**: an attacker modified pip config to add a public fallback

Either way, high-signal alert. Remediation: switch to `--index-url` (single registry) and verify lockfiles exist.

**Triage steps:**

1. Check which host made the request (CI runner? Developer workstation?)
2. Pull the pip.conf. Does it have `extra-index-url`?
3. Check what package was requested. Is it an internal package name on public PyPI?
4. If yes: treat as potential dependency confusion and escalate immediately

### CI Integration

Add this to your GitHub Actions pipeline to catch `extra-index-url` misconfigurations and missing lockfiles before they reach production.

**`.github/workflows/pip-config-check.yml`:**

```yaml
name: Dependency Resolution Safety Check

on:
  pull_request:
    paths:
      - "requirements*.txt"
      - "setup.py"
      - "setup.cfg"
      - "pyproject.toml"
      - "pip.conf"
      - ".pip/**"

jobs:
  check-pip-config:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Reject extra-index-url in pip config
        run: |
          echo "--- Scanning for extra-index-url usage ---"
          FOUND=0
          for f in pip.conf .pip/pip.conf setup.cfg pyproject.toml; do
            if [ -f "$f" ]; then
              if grep -qi "extra-index-url" "$f"; then
                echo "::error file=$f::BLOCKED: $f contains extra-index-url. Use --index-url instead."
                FOUND=1
              fi
            fi
          done
          for f in requirements*.txt; do
            if [ -f "$f" ]; then
              if grep -qi "\-\-extra-index-url" "$f"; then
                echo "::error file=$f::BLOCKED: $f contains --extra-index-url inline flag."
                FOUND=1
              fi
            fi
          done
          if [ "$FOUND" -eq 1 ]; then
            exit 1
          fi
          echo "PASS: No extra-index-url found."

      - name: Verify lockfile exists
        run: |
          if [ -f "requirements.lock" ] || [ -f "requirements-lock.txt" ] || \
             [ -f "poetry.lock" ] || [ -f "Pipfile.lock" ] || [ -f "pdm.lock" ]; then
            echo "PASS: Lockfile found."
          else
            echo "::error::No lockfile found. Run 'pip freeze > requirements.lock' and commit it."
            exit 1
          fi

      - name: Check version pins in requirements.txt
        run: |
          UNPINNED=0
          for f in requirements*.txt; do
            if [ -f "$f" ]; then
              while IFS= read -r line; do
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                [[ "$line" =~ ^[[:space:]]*$ ]] && continue
                [[ "$line" =~ ^- ]] && continue
                if ! echo "$line" | grep -q "=="; then
                  echo "::warning file=$f::Unpinned dependency: $line (use == for exact version)"
                  UNPINNED=1
                fi
              done < "$f"
            fi
          done
          if [ "$UNPINNED" -eq 1 ]; then
            echo "WARNING: Some dependencies are not pinned to exact versions."
          else
            echo "PASS: All dependencies are pinned."
          fi
```

---

## What You Learned

1. **`--extra-index-url` is dangerous**: it merges results from multiple sources and picks the highest version, regardless of source.
2. **`--index-url` is the fix**: single registry eliminates the attack vector.
3. **Lockfiles freeze versions**: `pip freeze` captures exact versions so builds are reproducible and resistant to new malicious versions.

## Further Reading

- [pip documentation: --extra-index-url](https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-extra-index-url)
- [Python Packaging: Dependency Specifiers](https://packaging.python.org/en/latest/specifications/dependency-specifiers/)
- [Tidelift: The danger of --extra-index-url](https://blog.tidelift.com/the-danger-of-extra-index-url-in-pip)
