# Lab 1.6: Phantom Dependencies

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

## Finding Phantom Dependencies in Production

Phantom dependency exploitation has two phases: *silent reliance* (your code uses undeclared packages) and *substitution* (an attacker publishes a malicious version that fills the gap).

What to look for:

- `depcheck` reports `require()` / `import` statements for packages not in `package.json`
- `npm ls <package>` shows a package as transitive, but your code imports it directly
- A previously-transitive package suddenly appears at a significantly higher version (e.g., `debug@4.3.4` to `debug@99.0.0`)
- New packages appear in `node_modules/` after `npm update` that were never in `package.json`
- Outbound network connections from packages that previously had no network activity

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| Supply Chain Compromise: Compromise Software Dependencies and Development Tools | **T1195.001** | Attacker publishes a malicious version of a commonly-used transitive package, exploiting implicit dependency relationships |
| Hijack Execution Flow | **T1574.002** | Attacker places a malicious package where the resolver will find it, exploiting npm's hoisting mechanism |

---

## How to Think About Detection

At this stage, detection is mostly about spotting code that relies on a package nobody explicitly declared.

Ask:

- Does your code import a package that is not in `package.json`?
- Did an update suddenly remove or replace a transitive package your app quietly depended on?
- Are you using `npm ci` and explicit declarations, or trusting hoisting to keep things working?

If your app depends on undeclared packages, you are already carrying hidden risk before an attacker shows up.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

---

## What You Learned

1. **Phantom dependencies are a ticking time bomb**: packages your code uses but doesn't declare can disappear or be replaced at any time.
2. **npm hoisting makes them invisible**: transitive deps at root `node_modules/` are accidentally importable.
3. **`depcheck` + explicit pinning + `npm ci`**: the defense stack that eliminates the attack surface.

## Further Reading

- [Phantom dependencies in Node.js (Rush.js)](https://rushjs.io/pages/advanced/phantom_deps/)
- [depcheck on npm](https://www.npmjs.com/package/depcheck)
- [Yarn PnP](https://yarnpkg.com/features/pnp/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
