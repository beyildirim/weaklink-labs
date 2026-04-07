# Lab 1.2: Dependency Confusion

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

## Catching Dependency Confusion in the Wild

Dependency confusion has a distinctive signature: **a build system installs a package from a public registry that shares a name with an internal package, at a suspiciously high version number**. Detection must happen at the network and process level. By the time you see it in application logs, the damage is done.

### Indicators

- **Version jump**: pip output showing `wl-auth` going from `1.0.0` to `99.0.0`
- **Wrong source**: pip downloading from `pypi.org` a package matching your internal namespace (`wl-*`, `internal-*`, `company-*`)
- **Process spawn**: `setup.py` spawning child processes during `pip install` (network calls, file writes, shell commands)
- **Outbound C2**: HTTP/DNS from a `pip install` process to attacker-controlled infrastructure
- **File drops**: new files appearing in `/tmp` during package installation

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Attacker publishes a malicious package to public PyPI to hijack the build process |
| **Command and Scripting Interpreter: Python** | [T1059.006](https://attack.mitre.org/techniques/T1059/006/) | `setup.py` executes arbitrary Python code during package installation |
| **Automated Exfiltration** | [T1020](https://attack.mitre.org/techniques/T1020/) | Malicious setup.py exfiltrates environment variables and credentials without user interaction |

---

### SOC Alert Rules

**"Internal package name resolved from public PyPI"** (proxy/DNS logs)

**"setup.py spawning curl/wget on build server"** (EDR)

**"Outbound POST from pip child process to external host"** (firewall)

Dependency confusion is not theoretical. It produced $130,000+ in bug bounties from Microsoft, Apple, and PayPal in a single disclosure. The attack requires zero authentication, zero network access to the target, and zero interaction from the victim.

### Triage Workflow

1. **Package name**: matches an internal namespace (`wl-*`, `internal-*`, `company-*`)? Escalate immediately.
2. **Version**: `99.0.0`, `999.0.0`, or any unusually high version are classic indicators.
3. **Process tree**: did `setup.py` spawn child processes? Legitimate packages almost never run `curl`, `wget`, or shell commands during installation.
4. **Exfiltration**: outbound connections to unfamiliar hosts, DNS queries with encoded subdomains, files created in `/tmp`.
5. **Blast radius**: every CI run that used `--extra-index-url` in the same timeframe may be compromised. Rotate all secrets.

---

### CI Integration

Add this workflow to block `--extra-index-url` usage and detect public package names that collide with internal namespaces. Save as `.github/workflows/dependency-confusion-check.yml`:

```yaml
name: Dependency Confusion Prevention

on:
  pull_request:
    paths:
      - "requirements*.txt"
      - "setup.py"
      - "setup.cfg"
      - "pyproject.toml"
      - "pip.conf"
      - ".pip/**"

permissions:
  contents: read

jobs:
  check-dependency-confusion:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Block extra-index-url usage
        run: |
          EXIT_CODE=0
          for f in pip.conf .pip/pip.conf setup.cfg pyproject.toml; do
            if [ -f "$f" ]; then
              if grep -qi "extra-index-url" "$f"; then
                echo "::error file=$f::BLOCKED: $f contains extra-index-url."
                echo "Use --index-url with a single private registry that proxies public packages."
                EXIT_CODE=1
              fi
            fi
          done
          for f in requirements*.txt; do
            if [ -f "$f" ]; then
              if grep -qi "\-\-extra-index-url" "$f"; then
                echo "::error file=$f::BLOCKED: $f contains --extra-index-url inline flag."
                EXIT_CODE=1
              fi
            fi
          done
          if [ "$EXIT_CODE" -eq 0 ]; then
            echo "PASS: No extra-index-url usage found."
          fi
          exit $EXIT_CODE

      - name: Check for internal namespace on public PyPI
        run: |
          INTERNAL_PREFIXES="wl- internal- company-"
          EXIT_CODE=0
          for f in requirements*.txt; do
            if [ -f "$f" ]; then
              while IFS= read -r line; do
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                [[ "$line" =~ ^[[:space:]]*$ ]] && continue
                [[ "$line" =~ ^- ]] && continue
                pkg=$(echo "$line" | sed 's/[>=<!=;\[].*//' | xargs | tr '[:upper:]' '[:lower:]' | tr '_' '-')
                [ -z "$pkg" ] && continue
                for prefix in $INTERNAL_PREFIXES; do
                  if [[ "$pkg" == ${prefix}* ]]; then
                    echo "::error file=$f::Package '$pkg' matches internal namespace prefix '$prefix'."
                    echo "Ensure this is installed from your private registry only."
                    EXIT_CODE=1
                  fi
                done
              done < "$f"
            fi
          done
          if [ "$EXIT_CODE" -eq 0 ]; then
            echo "PASS: No internal namespace collisions detected."
          fi
          exit $EXIT_CODE
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

1. **`--extra-index-url` is the root cause**: it tells pip to search multiple registries and pick the highest version, regardless of source.
2. **`setup.py` runs during install**: malicious code executes before you ever `import` the package.
3. **Version pins alone are not enough**: a developer loosening a pin or running `pip install --upgrade` reopens the vulnerability.

## Further Reading

- [Alex Birsan: Dependency Confusion (original disclosure)](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610)
- [Microsoft: 3 Ways to Mitigate Risk When Using Private Package Feeds](https://azure.microsoft.com/en-us/resources/3-ways-to-mitigate-risk-using-private-package-feeds/)
- [pip documentation: --extra-index-url](https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-extra-index-url)
