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

## How to Think About Detection

At this stage, detection is mostly about noticing when dependency resolution is happening in places you did not intend.

Ask:

- Did a build system contact a public registry when it should use a private one?
- Did the same package name suddenly resolve from a different source?
- Did a harmless version constraint change cause a large version jump?

Those are often configuration failures before they become full attacks.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

---

## What You Learned

1. **`--extra-index-url` is dangerous**: it merges results from multiple sources and picks the highest version, regardless of source.
2. **`--index-url` is the fix**: single registry eliminates the attack vector.
3. **Lockfiles freeze versions**: `pip freeze` captures exact versions so builds are reproducible and resistant to new malicious versions.

## Further Reading

- [pip documentation: --extra-index-url](https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-extra-index-url)
- [Python Packaging: Dependency Specifiers](https://packaging.python.org/en/latest/specifications/dependency-specifiers/)
- [Tidelift: The danger of --extra-index-url](https://blog.tidelift.com/the-danger-of-extra-index-url-in-pip)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
