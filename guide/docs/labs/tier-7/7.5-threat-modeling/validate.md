# Lab 7.5: Threat Modeling for Software Supply Chains

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step done">Investigate</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Validate</span>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Systematically apply STRIDE to each trust boundary and identify concrete threats.

## Worked example: TB-1 (Developer push)

For each trust boundary, ask the six STRIDE questions: Can an attacker **S**poof identity? **T**amper with data? Act without **R**epudiation? Cause **I**nformation disclosure? Cause **D**enial of service? **E**levate privilege?

| Threat | STRIDE | Likelihood | Impact |
|--------|--------|:----------:|:------:|
| Spoofed commit author | S | Medium | High |
| Tampered lockfile | T | Medium | Critical |
| Unsigned commits | R | High | Medium |
| Credential leak in commit | I | Medium | Critical |

**Gaps:** No commit signing enforcement, no lockfile integrity validation in PR checks.

## Worked example: TB-3 (Python dependency fetch)

| Threat | STRIDE | Likelihood | Impact |
|--------|--------|:----------:|:------:|
| Dependency confusion | S | Medium | Critical |
| Typosquatting | S | Medium | High |
| Compromised maintainer | T | Low | Critical |
| Malicious setup.py | E | Medium | Critical |

**Gaps:** Using `--extra-index-url`, no hash verification, no behavioral analysis.

## Your turn: TB-4 (Secret injection)

Apply STRIDE to the secret injection boundary. Secrets (API keys, tokens, credentials) are injected into CI runner environments during builds. Think about:

- Who/what can access these secrets?
- Can a malicious dependency read them?
- Are secrets scoped to only the pipelines that need them?

| Threat | STRIDE | Likelihood | Impact |
|--------|--------|:----------:|:------:|
| ? | ? | ? | ? |
| ? | ? | ? | ? |

**Gaps:** ?

??? tip "Solution"
    | Threat | STRIDE | Likelihood | Impact |
    |--------|--------|:----------:|:------:|
    | Over-privileged secrets | E | High | Critical |
    | Secret exfiltration via malicious dep | I | Medium | Critical |
    | `pull_request_target` secret leak | I | Medium | Critical |

    **Gaps:** No least-privilege secret scoping, no OIDC-based short-lived credentials.

## Your turn: TB-6 (Artifact publish)

Apply STRIDE to the artifact publish boundary. Docker images are pushed to ghcr.io after a successful build. Think about:

- Can an attacker overwrite an existing image tag?
- Can anyone verify who built an artifact and from what source?

| Threat | STRIDE | Likelihood | Impact |
|--------|--------|:----------:|:------:|
| ? | ? | ? | ? |

**Gaps:** ?

??? tip "Solution"
    | Threat | STRIDE | Likelihood | Impact |
    |--------|--------|:----------:|:------:|
    | Tag mutability | T | Medium | Critical |
    | Missing provenance | R | High | High |

    **Gaps:** No image signing (cosign), no SLSA provenance, tags not immutable.

## Build the full STRIDE summary

Using the worked examples above and your own analysis of TB-4 and TB-6, fill in the remaining boundaries (TB-2, TB-5, TB-7) and complete the summary table. Count the number of threats per STRIDE category for each boundary.

| Trust Boundary | S | T | R | I | D | E | Total |
|---------------|:-:|:-:|:-:|:-:|:-:|:-:|:-----:|
| TB-1: Developer push | 1 | 1 | 1 | 1 | 0 | 0 | 4 |
| TB-2: CI trigger | ? | ? | ? | ? | ? | ? | ? |
| TB-3: Python deps | 2 | 1 | 0 | 0 | 0 | 1 | 4 |
| TB-4: Secret injection | ? | ? | ? | ? | ? | ? | ? |
| TB-5: Node.js deps | ? | ? | ? | ? | ? | ? | ? |
| TB-6: Artifact publish | ? | ? | ? | ? | ? | ? | ? |
| TB-7: Deployment sync | ? | ? | ? | ? | ? | ? | ? |
| **Total** | ? | ? | ? | ? | ? | ? | ? |

Which STRIDE category dominates? What does that tell you about supply chain attacks?

??? tip "Solution"
    | Trust Boundary | S | T | R | I | D | E | Total |
    |---------------|:-:|:-:|:-:|:-:|:-:|:-:|:-----:|
    | TB-1: Developer push | 1 | 1 | 1 | 1 | 0 | 0 | 4 |
    | TB-2: CI trigger | 0 | 1 | 0 | 0 | 1 | 1 | 3 |
    | TB-3: Python deps | 2 | 1 | 0 | 0 | 0 | 1 | 4 |
    | TB-4: Secret injection | 0 | 0 | 0 | 2 | 0 | 1 | 3 |
    | TB-5: Node.js deps | 2 | 1 | 0 | 0 | 0 | 1 | 4 |
    | TB-6: Artifact publish | 0 | 2 | 1 | 0 | 0 | 0 | 3 |
    | TB-7: Deployment sync | 1 | 1 | 0 | 0 | 1 | 0 | 3 |
    | **Total** | **6** | **7** | **2** | **3** | **2** | **4** | **24** |

    Tampering (T) and Spoofing (S) dominate. This matches reality: most real-world supply chain attacks involve impersonating a trusted source or modifying a trusted artifact.
