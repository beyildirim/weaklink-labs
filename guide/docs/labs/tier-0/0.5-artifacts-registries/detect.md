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

## How to Think About Detection

At this stage, detection is mostly about noticing integrity mismatches early instead of trusting version numbers.

Ask:

- Did the same version suddenly produce a different hash?
- Did the package come from the registry you expected?
- Are your install logs and lockfiles enough to prove what was actually installed?

If you cannot answer those confidently, you do not yet have artifact trust. You only have artifact convenience.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

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
