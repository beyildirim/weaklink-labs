# Lab 1.4: Lockfile Injection

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

## Finding Lockfile Injection in Production

Lockfile injection leaves traces across three layers: source control audit logs, network traffic during builds, and process execution on build runners. Each individual signal looks mundane. The *combination* reveals the attack.

What to look for:

- A PR modifies **only** lockfile(s) with no change to manifest files (`requirements.in`, `package.json`, `Pipfile`)
- The PR author is a human account, not a bot (Dependabot/Renovate PRs modify both manifest and lock)
- Commit message says "update deps" / "ran pip-compile" but the manifest is untouched
- `pip install` spawning child processes (shell, curl, wget) during installation
- File writes to unexpected locations during `pip install`

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| Supply Chain Compromise: Compromise Software Dependencies | **T1195.002** | Replacing a legitimate dependency hash with a backdoored one |
| Phishing: Spearphishing Attachment (via code review) | **T1566.001** | The PR itself is the phishing vector, tricking a reviewer into approving malicious code |
| Subvert Trust Controls | **T1553** | Exploiting trust in the lockfile as an "auto-generated" artifact |

---

## How to Think About Detection

At this stage, detection is mostly about spotting a dependency change that looks routine but should raise review suspicion.

Ask:

- Did the PR change only the lockfile and nothing upstream of it?
- Does the lockfile claim to be regenerated even though the manifest did not change?
- Did the build install something you cannot explain from the manifest alone?

If the lockfile is the only thing that changed, treat it as source code, not build noise.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

---

## What You Learned

1. **Lockfile injection exploits review blindness**: lockfile diffs are large, "auto-generated," and reviewers skip them.
2. **Always regenerate lockfiles in CI**: compare against the committed version to catch tampered hashes.
3. **`--require-hashes` enforces integrity**: pip only installs packages matching expected hashes.

## Further Reading

- [Lockfile Injection (Snyk Research)](https://snyk.io/blog/why-npm-lockfiles-can-be-a-security-blindspot-for-injecting-malicious-modules/)
- [pip-compile documentation](https://pip-tools.readthedocs.io/)
- [SLSA Build Requirements](https://slsa.dev/spec/v1.0/requirements)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
