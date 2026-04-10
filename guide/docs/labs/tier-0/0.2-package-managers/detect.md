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

## How to Think About Detection

At this stage, focus on noticing install-time behavior that should never feel normal.

Ask:

- Did installation execute code outside the package directory?
- Did the installer contact anything other than the package index?
- Did it create files in `/tmp`, home directories, or startup locations?

If that happens during `pip install`, treat the package as hostile until proven otherwise.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

---

## What You Learned

- **`pip install` runs `setup.py`, which is arbitrary Python.** Installation equals code execution with the installing user's full privileges.
- **Hash checking pins exact content.** `--require-hashes` ensures you get the exact bytes you verified, not a tampered version.
- **Public registries are trusted by default but not verified.** You must explicitly verify what you install before trusting it.

## Further Reading

- [pip install --require-hashes documentation](https://pip.pypa.io/en/stable/topics/secure-installs/)
- [PyPI Malware: What You Need to Know](https://blog.phylum.io/pypi-malware/)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
