# Lab 6.5: Case Study: xz-utils (CVE-2024-3094)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step done">Analyze</a>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step done">Lessons</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Indicators of the xz-utils Backdoor

The backdoor was designed to be invisible at the application and network layer. Detection focused on **host-level indicators**: vulnerable liblzma version, SSH authentication latency, and unexpected sshd CPU usage.

**Key indicators:**

- liblzma version 5.6.0 or 5.6.1 installed
- SSH authentication taking >200ms longer than baseline
- `sshd` consuming unexpected CPU during authentication
- Release tarballs that do not match git source builds

| Indicator | What It Means |
|-----------|---------------|
| `dpkg -l liblzma5` showing 5.6.0 or 5.6.1 | Vulnerable version installed |
| `ldd /usr/sbin/sshd` showing liblzma linkage | sshd linked against potentially backdoored library |
| `sshd` CPU spike during key exchange | Backdoor executing during RSA verification |

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Backdoor injected into release tarballs via compromised maintainer |
| **Modify Authentication Process** | [T1556](https://attack.mitre.org/techniques/T1556/) | Backdoor hooked RSA signature verification in sshd |
| **Trusted Relationship** | [T1199](https://attack.mitre.org/techniques/T1199/) | Attacker gained access through social engineering of maintainer trust |

**Alert:** "Vulnerable liblzma version detected (CVE-2024-3094)"

**Triage steps:**

1. Query SBOM for liblzma 5.6.0/5.6.1
2. Check if sshd links against liblzma: `ldd /usr/sbin/sshd | grep lzma`
3. If linked on systemd-based distros, the system is exploitable
4. Downgrade to 5.4.x immediately
5. Check SSH access logs for the exposure window

---

### CI Integration

Add this workflow to detect sole-maintainer risk and tarball-vs-source divergence. Save as `.github/workflows/source-tarball-check.yml`:

```yaml
name: Source vs Tarball Integrity

on:
  pull_request:
    paths:
      - "requirements*.txt"
      - "pyproject.toml"
      - "go.sum"
      - "Cargo.lock"
  schedule:
    - cron: "0 6 * * 1"  # Weekly Monday check

permissions:
  contents: read

jobs:
  check-source-integrity:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check for single-maintainer dependencies
        run: |
          echo "--- Checking for sole-maintainer risk ---"
          echo "Dependencies with a single maintainer are high-risk targets"
          echo "for social engineering (xz-utils pattern)."
          echo ""
          echo "Review your critical dependencies for:"
          echo "  - Single maintainer with no co-maintainers"
          echo "  - Maintainer recently changed"
          echo "  - Low bus factor (only 1-2 active contributors)"
          echo ""
          # Check if pip-audit is available for vulnerability scanning
          if command -v pip-audit >/dev/null 2>&1; then
            pip-audit -r requirements.txt --desc 2>/dev/null || true
          else
            echo "Install pip-audit for automated vulnerability checks."
          fi

      - name: Detect build-from-source vs tarball differences
        run: |
          echo "--- Tarball vs Git Source Check ---"
          echo "The xz-utils backdoor existed ONLY in release tarballs,"
          echo "not in the git source. Verify your build process uses"
          echo "git tags, not release tarballs, for critical dependencies."
          echo ""
          # Flag any curl/wget of tarballs in build scripts
          TARBALL_DOWNLOADS=$(grep -rn 'curl.*\.tar\|wget.*\.tar' \
            --include='*.sh' --include='*.yml' --include='*.yaml' \
            --include='Dockerfile*' --include='Makefile' . || true)
          if [ -n "$TARBALL_DOWNLOADS" ]; then
            echo "::warning::Found tarball downloads in build scripts:"
            echo "$TARBALL_DOWNLOADS"
            echo ""
            echo "Prefer git clone with tag verification over tarball downloads."
          else
            echo "PASS: No direct tarball downloads found in build scripts."
          fi
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- **Social engineering is the most dangerous supply chain vector.** The attacker spent two years building trust, including sock puppet pressure campaigns.
- **Release tarballs can differ from git source.** The backdoor existed only in the tarball. Building from git tags prevents this class of attack.
- **Sole-maintainer projects are the highest-risk dependencies.** The entire attack was enabled by one overworked maintainer who could be socially engineered.

## Further Reading

- [Andres Freund's Original Disclosure (oss-security)](https://www.openwall.com/lists/oss-security/2024/03/29/4)
- [Evan Boehs: Everything I Know About the xz Backdoor](https://boehs.org/node/everything-i-know-about-the-xz-backdoor)
- [OpenSSF: Lessons from the xz-utils Compromise](https://openssf.org/blog/2024/03/30/xz-backdoor-cve-2024-3094/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
