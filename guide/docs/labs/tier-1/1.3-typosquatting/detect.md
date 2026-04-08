# Lab 1.3: Typosquatting

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

## Catching Typosquatting Before and After Installation

Typosquatting detection is a **string similarity problem combined with behavioral analysis**: (1) package names suspiciously close to popular packages, and (2) `setup.py` executing code unrelated to the package's purpose.

What to look for:

- pip installing a package 1-2 characters different from a top-1000 PyPI package
- `setup.py` reading environment variables, writing to `/tmp/`, or making outbound HTTP/DNS calls
- A package that imports and re-exports another package (wrapper pattern)
- Outbound connections to `webhook.site`, `pipedream.net`, `requestbin.com`, `burpcollaborator.net`

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Dependencies and Development Tools** | [T1195.001](https://attack.mitre.org/techniques/T1195/001/) | Attacker publishes a malicious package with a name designed to be confused with a legitimate one |
| **User Execution: Malicious File** | [T1204.002](https://attack.mitre.org/techniques/T1204/002/) | Developer executes `pip install <typosquat>` believing it to be the legitimate package |
| **Masquerading** | [T1036](https://attack.mitre.org/techniques/T1036/) | Typosquatted package masquerades as the legitimate one: same version, same description, wraps the real functionality |

---

### SOC Alert Rules

**Alerts:**

- "pip installed unrecognized package on build server" (EDR/allowlist)
- "setup.py spawned network connection to external host" (EDR)
- "Sensitive environment variables accessed during package installation" (EDR)

Unlike dependency confusion (which targets CI infrastructure), typosquatting targets **individual developers**. A single developer running `pip install reqeusts` compromises their entire credential set. The typosquatted package often **works correctly** because it wraps the legitimate one. All tests pass.

**Triage:**

1. Compare package name against PyPI top-1000. Levenshtein distance of 1-2 is almost certainly a typosquat.
2. Check package age on PyPI. Typosquats are usually recently published.
3. Inspect `setup.py` process tree during installation.
4. Rotate credentials immediately if exfiltration is confirmed.

### CI Integration

**`.github/workflows/typosquatting-check.yml`:**

```yaml
name: Typosquatting Prevention

on:
  pull_request:
    paths:
      - "requirements*.txt"
      - "setup.py"
      - "setup.cfg"
      - "pyproject.toml"

jobs:
  check-typosquatting:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install detection tools
        run: pip install python-Levenshtein

      - name: Check for typosquatted packages
        run: |
          python3 << 'PYEOF'
          import sys
          import re
          from pathlib import Path

          try:
              from Levenshtein import distance as levenshtein_distance
          except ImportError:
              def levenshtein_distance(s1, s2):
                  if len(s1) < len(s2):
                      return levenshtein_distance(s2, s1)
                  if len(s2) == 0:
                      return len(s1)
                  prev_row = range(len(s2) + 1)
                  for i, c1 in enumerate(s1):
                      curr_row = [i + 1]
                      for j, c2 in enumerate(s2):
                          insertions = prev_row[j + 1] + 1
                          deletions = curr_row[j] + 1
                          substitutions = prev_row[j] + (c1 != c2)
                          curr_row.append(min(insertions, deletions, substitutions))
                      prev_row = curr_row
                  return prev_row[-1]

          KNOWN_PACKAGES = [
              "requests", "numpy", "pandas", "flask", "django", "boto3",
              "urllib3", "setuptools", "pip", "wheel", "cryptography",
              "pyyaml", "pyjwt", "pillow", "scipy", "matplotlib",
              "beautifulsoup4", "sqlalchemy", "celery", "redis",
              "psycopg2", "pymongo", "colorama", "paramiko", "jinja2",
              "click", "pytest", "coverage", "tox", "black", "flake8",
              "mypy", "isort", "pylint", "httpx", "aiohttp", "fastapi",
              "uvicorn", "gunicorn", "pydantic", "python-dateutil",
              "python-dotenv", "python-multipart", "docker", "kubernetes",
              "protobuf", "grpcio", "tensorflow", "torch", "transformers",
              "scrapy", "selenium", "ansible", "fabric", "invoke",
          ]

          issues_found = 0
          for req_file in Path(".").glob("requirements*.txt"):
              with open(req_file) as f:
                  for line_num, line in enumerate(f, 1):
                      line = line.strip()
                      if not line or line.startswith("#") or line.startswith("-"):
                          continue
                      pkg = re.split(r"[>=<!;\[]", line)[0].strip()
                      if not pkg:
                          continue
                      pkg_norm = pkg.lower().replace("_", "-")
                      if pkg_norm in KNOWN_PACKAGES:
                          continue
                      for known in KNOWN_PACKAGES:
                          dist = levenshtein_distance(pkg_norm, known)
                          if dist == 1:
                              print(
                                  f"::error file={req_file},line={line_num}::"
                                  f"TYPOSQUATTING RISK: '{pkg}' is 1 edit away from "
                                  f"'{known}'. Verify this is the correct package."
                              )
                              issues_found += 1
                          elif dist == 2 and len(pkg_norm) > 5:
                              print(
                                  f"::warning file={req_file},line={line_num}::"
                                  f"Possible typosquat: '{pkg}' is 2 edits from "
                                  f"'{known}'. Please verify."
                              )

          if issues_found > 0:
              print(f"\nFound {issues_found} potential typosquatting issue(s).")
              sys.exit(1)
          else:
              print("PASS: No typosquatting risks detected.")
          PYEOF

      - name: Enforce package allowlist
        run: |
          ALLOWLIST_FILE="allowed-packages.txt"
          if [ ! -f "$ALLOWLIST_FILE" ]; then
            echo "::warning::No allowed-packages.txt found. Create one to enforce an allowlist."
            exit 0
          fi
          BLOCKED=0
          for f in requirements*.txt; do
            if [ -f "$f" ]; then
              while IFS= read -r line; do
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                [[ "$line" =~ ^[[:space:]]*$ ]] && continue
                [[ "$line" =~ ^- ]] && continue
                pkg=$(echo "$line" | sed 's/[>=<!=;\[].*//' | xargs | tr '[:upper:]' '[:lower:]' | tr '_' '-')
                [ -z "$pkg" ] && continue
                if ! grep -qi "^${pkg}$" "$ALLOWLIST_FILE"; then
                  echo "::error file=$f::BLOCKED: Package '${pkg}' is not in the allowlist ($ALLOWLIST_FILE)."
                  BLOCKED=1
                fi
              done < "$f"
            fi
          done
          if [ "$BLOCKED" -eq 1 ]; then
            exit 1
          fi
          echo "PASS: All packages are on the allowlist."
```

---

## What You Learned

1. **Typosquatting exploits human error**: attackers register package names one keystroke away from popular packages.
2. **`setup.py` runs during install**: secrets are stolen before you ever import the package.
3. **Functional wrappers evade detection**: malicious packages wrap the real one, passing all tests while exfiltrating data.

## Further Reading

- [PyPI Typosquatting Research (Phylum, 2023)](https://blog.phylum.io/pypi-malware-replaces-crypto-addresses-in-developers-clipboard)
- [Typosquatting in Python Ecosystem (arxiv)](https://arxiv.org/abs/2005.09535)
- [pip-audit](https://github.com/pypa/pip-audit)
