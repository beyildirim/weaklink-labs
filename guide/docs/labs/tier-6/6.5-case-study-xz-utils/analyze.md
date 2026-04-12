# Lab 6.5: Case Study: xz-utils (CVE-2024-3094)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Analyze</span>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## The Backdoor Mechanism

**Goal:** Walk through how the backdoor was injected via the build system and how it targeted SSH authentication.

### Step 1: Create a simple detector script

```bash
cat > /app/detect_xz_backdoor.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-/app}"
INDICATORS_FILE="${TARGET}/indicators/iocs.txt"

if grep -Eqi 'bad-3-corrupt_lzma2\.xz|m4 macro|liblzma|5\.6\.0|5\.6\.1' "$INDICATORS_FILE"; then
  echo "BACKDOOR DETECTED: suspicious xz-utils release indicators present"
  grep -Ei 'bad-3-corrupt_lzma2\.xz|m4 macro|liblzma|5\.6\.0|5\.6\.1' "$INDICATORS_FILE" || true
else
  echo "No suspicious indicators found"
  exit 1
fi
EOF

chmod +x /app/detect_xz_backdoor.sh
bash /app/detect_xz_backdoor.sh /app
```

This is intentionally simple. The important part is capturing the release-only indicators: vulnerable versions, suspicious test fixtures, and the build-system clues called out in the IOC notes.

### Step 2: Capture the build-system analysis

```bash
cat >> /app/analysis.md <<'EOF'

## Build system injection
The payload was hidden behind `m4/build-to-host.m4` and executed during `./configure`,
which is why this was a build script problem instead of a normal source review problem.

The release artifact path mattered: a release tarball could include files that were not
visible in a clean git checkout. The resulting liblzma compromise reached sshd through
system library linkage, and the backdoor relied on IFUNC-style hooking to stay difficult
to spot during normal review.
EOF
```

The verification script looks for the specific technical markers above: `m4`, build script behavior, `configure`, `ifunc`, and `liblzma`.

### Step 3: Connect it back to SSH impact

The attack path: liblzma is linked by libsystemd (journal compression), libsystemd is linked by sshd on systemd-based distros. The backdoor hooked RSA signature verification in OpenSSH. A specially crafted SSH public key triggered the backdoor, decrypting and executing the payload as root.

> **Checkpoint:** You should now have `/app/detect_xz_backdoor.sh` plus an `/app/analysis.md` file that explains why release tarballs, `m4/build-to-host.m4`, `./configure`, `IFUNC`, and `liblzma` mattered.
