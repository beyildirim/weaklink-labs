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

## How to Think About Detection

At this stage, detection is mostly about noticing a package that is close enough to look safe but behaves too strangely to trust.

Ask:

- Is the package name only one or two keystrokes away from a well-known one?
- Did installation access secrets, write to `/tmp`, or make outbound connections?
- Does the package work normally while doing something unrelated in the background?

That combination is what makes typosquatting dangerous. It does not need to break your app to compromise your environment.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

---

## What You Learned

1. **Typosquatting exploits human error**: attackers register package names one keystroke away from popular packages.
2. **`setup.py` runs during install**: secrets are stolen before you ever import the package.
3. **Functional wrappers evade detection**: malicious packages wrap the real one, passing all tests while exfiltrating data.

## Further Reading

- [PyPI Typosquatting Research (Phylum, 2023)](https://blog.phylum.io/pypi-malware-replaces-crypto-addresses-in-developers-clipboard)
- [Typosquatting in Python Ecosystem (arxiv)](https://arxiv.org/abs/2005.09535)
- [pip-audit](https://github.com/pypa/pip-audit)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
