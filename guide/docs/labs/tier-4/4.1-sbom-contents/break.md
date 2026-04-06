# Lab 4.1: What SBOMs Actually Contain

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

## What SBOMs Miss

**Goal:** Discover the blind spots. SBOMs are not complete inventories.

### Step 1: Check the vendored C library

```bash
ls -la /app/vendor/
strings /app/vendor/libcurl.so | grep -i "libcurl/"
```

Check if the SBOM found it:

```bash
cat /app/sbom-cdx.json | jq '.components[] | select(.name | test("curl"; "i"))'
```

Nothing. The SBOM tool scanned package manager manifests but does not analyze compiled binaries. The vendored library is invisible.

### Step 2: Check for dynamically loaded modules

```bash
grep -r "importlib\|__import__\|load_module\|dlopen" /app/src/
```

The application uses `importlib.import_module()` to load a plugin at runtime. This plugin is not in `requirements.txt` and won't appear in any SBOM.

### Step 3: Check for build-time dependencies

```bash
cat /app/Makefile
```

The Makefile shows `gcc`, `make`, and `cmake` were used to compile the vendored library. None appear in the SBOM. If any were compromised (like the XZ Utils attack), the SBOM gives zero signal.

### Step 4: Check for Helm/infrastructure references

```bash
cat /app/deploy/values.yaml 2>/dev/null
```

Helm chart references, base images, and sidecar containers are not captured in the application SBOM.

### Step 5: Quantify the gap

| Component | In SBOM? | Why Not? |
|-----------|----------|----------|
| Python packages (Flask, requests, etc.) | Yes | Declared in requirements.txt |
| vendored libcurl 7.79.0 | **No** | Compiled binary, no package manager metadata |
| Runtime plugin (loaded via importlib) | **No** | Dynamic dependency, not declared anywhere |
| Build tools (gcc, cmake) | **No** | Not runtime dependencies |
| Base container image packages | **No** | Syft scanned /app, not the full image |
| Helm chart references | **No** | Infrastructure, not application code |

An SBOM listing 12 packages when the real count is 18+ creates a **false sense of security**.
