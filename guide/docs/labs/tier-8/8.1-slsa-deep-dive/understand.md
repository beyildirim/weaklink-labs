# Lab 8.1: SLSA Framework Deep Dive

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../assess/" class="phase-step upcoming">Assess</a>
  <span class="phase-arrow">›</span>
  <a href="../plan/" class="phase-step upcoming">Plan</a>
  <span class="phase-arrow">›</span>
  <a href="../document/" class="phase-step upcoming">Document</a>
</div>

**Goal:** Learn the SLSA levels, build track requirements, and what each level prevents.

## Step 1: SLSA levels overview

SLSA v1.0 defines a Build track with four levels. See [slsa.dev/spec/v1.0](https://slsa.dev/spec/v1.0/) for the full specification.

| Level | What It Means | Trust Assumption |
|:-----:|--------------|-----------------|
| **0** | No provenance | Trust everyone |
| **1** | Provenance exists (not tamper-resistant) | Trust the build service not to lie |
| **2** | Hosted build, authenticated provenance | Trust the hosted build service |
| **3** | Hardened builds, non-falsifiable provenance | Trust the build service infrastructure |

## Step 2: Provenance requirements per level

| Field | L1 | L2 | L3 |
|-------|:--:|:--:|:--:|
| Subject (artifact hash) | Required | Required | Required |
| Build type | Required | Required | Required |
| Source reference (repo + commit) | Required | Required | Required |
| Builder identity | Optional | Required | Required |
| Authenticated provenance | No | Yes (signed) | Yes (non-falsifiable) |
| Isolated build environment | No | No | Yes |
| Parameterless build | No | No | Yes |

## Step 3: What each level prevents

| Attack | L0 | L1 | L2 | L3 |
|--------|:--:|:--:|:--:|:--:|
| No provenance at all | Vulnerable | **Prevented** | Prevented | Prevented |
| Developer builds on laptop and uploads | Vulnerable | Vulnerable | **Prevented** | Prevented |
| CI admin falsifies provenance | Vulnerable | Vulnerable | Vulnerable | **Prevented** |
| Attacker compromises build script parameters | Vulnerable | Vulnerable | Vulnerable | **Prevented** |
