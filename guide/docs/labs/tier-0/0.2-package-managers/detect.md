# Lab 0.2: How Package Managers Work

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

## Spotting Malicious Package Installations

What to look for:

- Packages installed that are not in `requirements.txt`
- Package names similar to popular libraries (typosquatting: `reqeusts`, `colorsama`)
- File creation in `/tmp/`, `/dev/shm/`, or home directories during `pip install`
- Outbound HTTP/DNS requests during installation (should only contact the package index)
- Child processes of `setup.py` that spawn shells or open network sockets

### MITRE ATT&CK Mapping

| Technique | ID | What to Monitor |
|-----------|----|-----------------|
| Compromise Software Supply Chain | T1195.002 | Unexpected packages, typosquatting names |
| Python Execution | T1059.006 | setup.py spawning shells, writing outside site-packages |
| Malicious File | T1204.002 | File writes to /tmp during install, cron/systemd creation |

---

### SOC Alert Rules

When you see **"Unexpected outbound connection during build"** or **"Process spawned by pip/setup.py writing to /tmp"**: a `pip install` ran a package with a malicious `setup.py`. The payload executed immediately during installation with the full privileges of the installing user (often root in CI containers). Correlate the timestamp with pip install logs to identify which package triggered it, then inspect that package's `setup.py`.

### CI Integration

Add this GitHub Actions workflow to enforce hash-verified installs in CI. Save as `.github/workflows/dependency-check.yml`:

```yaml
name: Dependency Hash Verification

on:
  pull_request:
    paths:
      - 'requirements*.txt'
      - 'setup.py'
      - 'setup.cfg'
      - 'pyproject.toml'
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  verify-hashes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Verify requirements.txt has hashes
        run: |
          if [ -f requirements.txt ]; then
            if ! grep -q -- '--hash=sha256:' requirements.txt; then
              echo "::error::requirements.txt must use --hash=sha256: for all packages."
              echo "Generate hashes with: pip-compile --generate-hashes requirements.in"
              exit 1
            fi
          fi

      - name: Install with --require-hashes
        run: |
          pip install --require-hashes -r requirements.txt
        env:
          PIP_NO_CACHE_DIR: "1"

      - name: Verify no unexpected packages
        run: |
          # List installed packages and compare to requirements
          pip freeze > /tmp/installed.txt
          echo "Installed packages:"
          cat /tmp/installed.txt
```

---

## What You Learned

- **`pip install` runs `setup.py`, which is arbitrary Python.** Installation equals code execution with the installing user's full privileges.
- **Hash checking pins exact content.** `--require-hashes` ensures you get the exact bytes you verified, not a tampered version.
- **Public registries are trusted by default but not verified.** You must explicitly verify what you install before trusting it.

## Further Reading

- [pip install --require-hashes documentation](https://pip.pypa.io/en/stable/topics/secure-installs/)
- [PyPI Malware: What You Need to Know](https://blog.phylum.io/pypi-malware/)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
