# Lab 8.1: SLSA Framework Deep Dive

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Assess</span>
  <span class="phase-arrow">›</span>
  <a href="../plan/" class="phase-step upcoming">Plan</a>
  <span class="phase-arrow">›</span>
  <a href="../document/" class="phase-step upcoming">Document</a>
</div>

**Goal:** Evaluate the sample application against SLSA requirements.

## Step 1: Audit the build process

```bash
cat /app/.github/workflows/build.yml
```

Read the workflow file and fill in the assessment table:

| Requirement | Status | Evidence |
|-------------|--------|----------|
| **Provenance generated** | [Your assessment] | [What did you find?] |
| **Provenance authenticated** | [Your assessment] | [Is it signed? By whom?] |
| **Hosted build** | [Your assessment] | [What runner type?] |
| **Isolated build** | [Your assessment] | [Ephemeral or persistent?] |
| **Parameterless** | [Your assessment] | [Any workflow_dispatch inputs?] |

## Step 2: Gather evidence

Search the build workflows for provenance-related tooling:

```bash
grep -r "slsa-framework\|cosign\|attestation\|provenance" /app/.github/workflows/ 2>/dev/null
grep -r "actions/attest-build-provenance" /app/.github/workflows/ 2>/dev/null
grep -r "workflow_dispatch" /app/.github/workflows/ 2>/dev/null
grep -r "runs-on:" /app/.github/workflows/ 2>/dev/null
```

## Step 3: Determine current level

Based on your evidence, what SLSA level does this project meet?

| Requirement | Met? | Notes |
|-------------|------|-------|
| Provenance exists | [Y/N] | [Your evidence] |
| Hosted build platform | [Y/N] | [Your evidence] |
| Authenticated provenance | [Y/N] | [Your evidence] |
| Isolated build | [Y/N/Partial] | [Your evidence] |
| Parameterless | [Y/N] | [Your evidence] |

**Current SLSA Level: ?**

??? example "Expected findings"
    | Requirement | Met? | Notes |
    |-------------|------|-------|
    | Provenance exists | No | No attestation step in the workflow |
    | Hosted build platform | Yes | GitHub Actions runners |
    | Authenticated provenance | No | Nothing to authenticate |
    | Isolated build | Partial | GitHub-hosted = ephemeral; self-hosted = not |
    | Parameterless | No | `workflow_dispatch` accepts parameters |

    **Current SLSA Level: 0**. The project builds on a hosted platform but generates no provenance.

---

???+ success "Checkpoint"
    You should have a clear assessment of the project's current SLSA level with evidence for each requirement. This assessment is the input to the roadmap.
