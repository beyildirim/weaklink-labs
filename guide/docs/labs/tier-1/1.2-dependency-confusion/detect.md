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

## How to Think About Detection

At this stage, detection is about recognizing a package install that clearly crossed a trust boundary.

Ask:

- Did an internal package name resolve from a public source?
- Did the installed version jump to something obviously abnormal?
- Did installation immediately spawn child processes, file drops, or outbound traffic?

If those line up, treat it as a high-confidence compromise, not a routine dependency issue.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

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

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
