# Lab 6.8: Case Study: event-stream / ua-parser-js

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

## Protecting Against Maintainer Takeover

**Goal:** Implement controls that detect and prevent both social engineering and account compromise.

### Lesson 1: Monitor maintainer changes

```bash
/app/defenses/check-maintainers.sh event-stream
```

Compares current npm maintainers against a known-good baseline. Any change triggers an alert requiring manual review before `npm install` proceeds.

### Lesson 2: Lock the full dependency tree

```bash
/app/defenses/detect-new-deps.sh
```

Compares current `package-lock.json` against a baseline snapshot. The addition of `flatmap-stream` would have appeared as an unexplained new entry in the diff.

If teams reviewed lockfile changes, the addition of `flatmap-stream` would have been visible. PR review policies should require explicit approval for any lockfile change that adds a new package.

### Lesson 3: Enforce 2FA for npm publishing

The ua-parser-js attack would have been prevented if the maintainer had 2FA enabled. Use `npm profile enable-2fa auth-and-writes` and automation tokens (not user tokens) for CI.

### Lesson 4: Use provenance attestation

npm provenance (since npm 9.5.0): packages built on GitHub Actions include provenance attestation. `npm audit signatures` verifies packages were published from known CI systems. Even with stolen credentials, the attacker cannot generate valid provenance.
