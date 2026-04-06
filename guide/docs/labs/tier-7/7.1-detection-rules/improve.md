# Lab 7.1: Building Detection Rules for Supply Chain Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step done">Investigate</a>
  <span class="phase-arrow">›</span>
  <a href="../validate/" class="phase-step done">Validate</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Improve</span>
</div>

**Goal:** Reduce false positives and build a detection coverage matrix.

## False positive tuning

| Rule | Common False Positives | Tuning Strategy |
|------|----------------------|-----------------|
| Internal pkg on public PyPI | Legitimate internal packages published to PyPI intentionally | Allow-list of packages on both registries by design |
| Typosquat watchlist | Niche packages with similar names | Only alert on edit distance 1-2 of top-1000 PyPI packages |
| Lockfile without manifest | Dependabot/Renovate PRs updating transitive deps only | Exclude known bot accounts |
| setup.py child process | Packages that compile C extensions | Filter out `gcc`, `g++`, `make`, `cmake` |
| High version number | Legitimate high-version packages (e.g., `Pillow==10.2.0`) | Threshold >50 for major version, cross-reference with internal names |

## Detection coverage matrix

| Attack Type | Proxy/DNS | EDR | CI/CD Logs | Git Audit | Registry Audit |
|-------------|:---------:|:---:|:----------:|:---------:|:--------------:|
| Dependency confusion | Rule 1 | Rule 4 | Rule 5 |. |. |
| Typosquatting |. |. | Rule 2 |. |. |
| Lockfile injection |. |. |. | Rule 3 |. |
| Manifest confusion |. |. |. |. | Partial |
| Phantom dependencies |. |. | Build failure |. |. |
| Exfiltration (any type) | Rule 4 (Suricata) | Rule 4 |. |. |. |

**Coverage gaps:**

- **Manifest confusion**: No reliable automated detection from logs alone. Requires pre-install validation.
- **Phantom dependencies**: Detection relies on build failures. Proactive detection requires dependency graph analysis.
- **Typosquatting**: Watchlist-based detection only catches known typosquats. New ones require fuzzy matching or Socket.dev integration.

## Final verification

```bash
weaklink verify 7.1
```

## What You Learned

- Supply chain attacks leave traces in multiple log sources, but the detection window between package install and exfiltration is minutes. Rules must fire on near-real-time telemetry.
- False positive tuning (allow-lists, bot exclusions, thresholds) is what makes detection rules production-viable.
- No single detection strategy catches all supply chain attacks. Layered detection across multiple log sources is required.

## Further Reading

- [MITRE ATT&CK: Supply Chain Compromise](https://attack.mitre.org/techniques/T1195/)
- [OpenSSF: Detecting Supply Chain Attacks](https://openssf.org/)
- [Suricata Rule Writing Guide](https://docs.suricata.io/en/latest/rules/)
