# Lab 1.6: Phantom Dependencies

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## What Phantom Dependencies Are

Focus on the hidden dependency relationship, not just the Node.js behavior. The risk is that your code works only because of someone else's package layout, which means your trust boundary is already unclear.

A phantom (or implicit) dependency is a package your code `require()`s that is NOT listed in your `package.json`. It exists in `node_modules/` only because another package depends on it, and npm hoists transitive dependencies to the root.

### Step 1: Look at your app

```bash
cat /app/package.json
```

Dependencies: only `wl-framework`. No `debug`.

```bash
cat /app/app.js
```

But the code does `require('debug')`.

### Step 2: Install and run

```bash
cd /app
npm install
node app.js
```

It works. But why?

### Step 3: Understand hoisting

```bash
ls node_modules/debug/
npm ls debug
```

`debug@4.3.4` is a dependency of `wl-framework@1.0.0`. npm hoisted it to `node_modules/debug/` at the root, making it accessible to your code even though you never declared it.

### Step 4: Find phantom dependencies with depcheck

```bash
depcheck /app
```

`depcheck` reports `debug` as a missing dependency: used in code but not in `package.json`.

Your code depends on an implementation detail of `wl-framework`. If `wl-framework` drops or changes `debug`, your app breaks.
