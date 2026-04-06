# Lab 7.1: Building Detection Rules for Supply Chain Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step done">Investigate</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Validate</span>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Write Sigma detection rules for each attack type, then validate them against the sample logs.

## Rule 1: Dependency confusion. Internal package fetched from public PyPI

The indicator from Investigate: proxy logs show a request to `pypi.org` for a package matching your internal naming convention.

```bash
mkdir -p /app/rules

cat > /app/rules/rule-1-depconf.yml << 'SIGMA'
title: Internal Package Name Resolved from Public PyPI
status: experimental
description: Proxy log shows pip fetching a package matching internal naming patterns from public PyPI.
logsource:
    category: proxy
detection:
    selection:
        url|contains: 'pypi.org/simple/'
    internal_names:
        url|contains:
            - '/wl-'
            - '/internal-'
            - '/corp-'
    condition: selection and internal_names
level: critical
tags:
    - attack.t1195.002
SIGMA
```

Validate against the sample logs:

```bash
grep "pypi.org.*wl-" /app/logs/proxy.log && echo "MATCH: Rule 1 would fire"
```

## Rule 2: Typosquatting. Known misspelling installed

The indicator: pip installs a package whose name is edit-distance 1-2 from a popular package.

```bash
cat > /app/rules/rule-2-typosquat.yml << 'SIGMA'
title: Known Typosquat Package Installed
status: experimental
description: pip installed a package matching a known typosquat of a popular package.
logsource:
    category: application
    product: pip
detection:
    selection:
        message|contains:
            - 'Collecting reqeusts'
            - 'Collecting requets'
            - 'Collecting requsts'
            - 'Collecting requestss'
    condition: selection
level: high
tags:
    - attack.t1195.001
SIGMA
```

Validate:

```bash
grep -iE "reqeusts|requets|requsts|requestss" /app/logs/pip.log && echo "MATCH: Rule 2 would fire"
```

## Rule 3: Lockfile injection. Lockfile changed without manifest change

The indicator: a PR modifies `package-lock.json` without touching `package.json`.

```bash
cat > /app/rules/rule-3-lockfile.yml << 'SIGMA'
title: Lockfile Modified Without Manifest Change
status: experimental
description: Git PR changed a lockfile but not the corresponding manifest, indicating possible lockfile injection.
logsource:
    category: vcs
    product: github
detection:
    lockfile_changed:
        files_changed|contains:
            - 'package-lock.json'
            - 'yarn.lock'
            - 'Pipfile.lock'
    manifest_unchanged:
        files_changed|contains:
            - 'package.json'
            - 'Pipfile'
            - 'requirements.txt'
    condition: lockfile_changed and not manifest_unchanged
level: high
tags:
    - attack.t1195.002
SIGMA
```

Validate:

```bash
grep "package-lock.json" /app/logs/github-audit.log | grep -v "package.json" && echo "MATCH: Rule 3 would fire"
```

## Rule 4: Exfiltration during package install. setup.py spawning network tools

The indicator: EDR shows a process tree where `pip -> python setup.py -> curl/wget/nc`.

```bash
cat > /app/rules/rule-4-exfil.yml << 'SIGMA'
title: Suspicious Child Process from Package Installation
status: experimental
description: setup.py spawned a network tool during pip install, indicating exfiltration or C2.
logsource:
    category: process_creation
    product: linux
detection:
    parent_chain:
        ParentCommandLine|contains: 'setup.py install'
    suspicious_child:
        CommandLine|contains:
            - 'curl '
            - 'wget '
            - 'nc '
            - 'ncat '
            - '/dev/tcp/'
    condition: parent_chain and suspicious_child
level: critical
tags:
    - attack.t1059.006
    - attack.t1020
SIGMA
```

Validate:

```bash
jq 'select(.parent.cmdline | contains("setup.py")) | select(.process.name == "curl" or .process.name == "wget")' /app/logs/edr.json && echo "MATCH: Rule 4 would fire"
```

## Rule 5: High-version package install (dependency confusion indicator)

The indicator: pip installs a package with a suspiciously high major version (>50), cross-referenced with internal naming patterns.

```bash
cat > /app/rules/rule-5-highver.yml << 'SIGMA'
title: Suspiciously High Package Version Installed
status: experimental
description: pip installed a package with major version >50, a classic dependency confusion indicator.
logsource:
    category: application
    product: pip
detection:
    selection:
        message|re: 'Successfully installed .*-[5-9][0-9]\.|.*-[0-9]{3,}\.'
    internal_context:
        message|contains:
            - 'wl-'
            - 'internal-'
            - 'corp-'
    condition: selection and internal_context
level: critical
tags:
    - attack.t1195.002
SIGMA
```

Validate:

```bash
grep -E "wl-auth-99\." /app/logs/pip.log && echo "MATCH: Rule 5 would fire"
```

## Validate all rules

```bash
echo "=== Rule files created ==="
ls -la /app/rules/
echo ""
echo "=== Validation summary ==="
for rule in /app/rules/rule-*.yml; do
    NAME=$(grep "^title:" "$rule" | cut -d: -f2-)
    echo "  $rule:$NAME"
done
```
