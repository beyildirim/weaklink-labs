# Lab 6.6: Case Study. SolarWinds (SUNBURST)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step done">Analyze</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Lessons</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Build Verification and Provenance

**Goal:** Implement build system controls that would detect or prevent a SUNBURST-style attack.

### Lesson 1: Reproducible builds

```bash
/app/defenses/reproducible-build.sh
```

An independent rebuild from the same source code would have produced a different binary than the one distributed. Reproducible builds make build tampering detectable.

### Lesson 2: Build system isolation

The SolarWinds build system was on the same network as corporate infrastructure. Modern build security requires:

- Air-gapped build environments
- Ephemeral build runners (no persistent state)
- No human SSH access to build systems
- Signing keys in an HSM accessible only by the pipeline

### Lesson 3: Binary transparency

```bash
cat /app/defenses/binary-transparency.sh
```

Binary transparency logs (Sigstore's Rekor) create a public, append-only record of every artifact. If two different binaries exist for the same version, the discrepancy is visible.

### Lesson 4: Two-person integrity for releases

No single person or process should modify the build pipeline AND sign the release. Separating them requires the attacker to compromise two independent systems.

### Verify understanding

```bash
weaklink verify 6.6
```
