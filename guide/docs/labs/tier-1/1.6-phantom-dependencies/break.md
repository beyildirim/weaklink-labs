# Lab 1.6: Phantom Dependencies

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## When the Phantom Disappears (or Gets Replaced)

### Part A: The reliability failure

#### Step 1: Publish the updated wl-framework

This command publishes a malicious version of wl-framework to the npm registry, simulating an attacker who claims an unclaimed transitive dependency:

```bash
publish-attack
```

Publishes `wl-framework@2.0.0` (no longer depends on `debug`) and a malicious `debug@99.0.0`.

#### Step 2: Update your dependencies

```bash
cd /workspace
npm update
```

npm upgrades `wl-framework` to v2.0.0. Since v2 doesn't depend on `debug`, npm may remove it or resolve the malicious v99.

#### Step 3: Try running the app

```bash
node app.js
```

One of two things happens:

1. **`debug` is gone**: `Cannot find module 'debug'`
2. **`debug@99.0.0` is resolved**: the app runs but you've been compromised

#### Step 4: Check for compromise

```bash
cat /tmp/phantom-dep-pwned 2>/dev/null
```

If this file exists, the malicious `debug@99.0.0` was installed and executed its payload.

### Part B: The supply chain attack

The attack vector:

1. Attacker identifies popular packages used as phantom dependencies (`debug`, `ms`, `qs`)
2. Attacker waits for the upstream package to drop the dependency
3. Attacker publishes a higher-version malicious package
4. npm resolves the attacker's version for anyone who didn't declare it explicitly

```bash
npm ls debug
cat node_modules/debug/package.json | grep version
```

**Checkpoint:** You should now have either a crashed app (missing `debug`) or a compromised app (`debug@99.0.0` with `/tmp/phantom-dep-pwned` present).
