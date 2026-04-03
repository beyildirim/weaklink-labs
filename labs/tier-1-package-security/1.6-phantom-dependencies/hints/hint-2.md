# Hint 2: The Fix

The defense is simple: **explicitly declare every package your code imports**.

1. Run `depcheck /workspace` to find phantom dependencies
2. Add each one to `package.json` with a pinned version
3. Regenerate the lockfile

For this lab:
- `debug` needs to be added to `dependencies` in `package.json`
- Use version `4.3.4` (the known-good version, not `99.0.0`)
- Pin it exactly: `"debug": "4.3.4"` (no `^` or `~`)
