# Lab 4.2: SBOM Gaps in Practice

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

## Catching SBOM Gaps Before They Become Blind Spots

**What to look for:**

- Container images with vendor directories containing `.so`, `.a`, or `.dll` files not in the SBOM
- SBOM component count significantly lower than actual package count inside the container
- Vulnerability scan findings for CVEs in packages absent from the SBOM
- SBOM generation logs showing warnings about unrecognized file types

| Indicator | What It Means |
|-----------|---------------|
| `/vendor/*.so` or `/third-party/*.a` in container | Compiled vendored deps likely missing from SBOM |
| SBOM has 0 components of type "library" (native) | Tool only found package manager deps |
| `find / -name "*.so" | wc -l` >> SBOM library count | Gap between actual and declared libraries |

### CI Integration

Add binary gap detection to your pipeline:

```yaml
- name: Check for vendored binaries not in SBOM
  run: |
    docker run --rm $IMAGE find /app -name "*.so" -o -name "*.a" | while read f; do
      LIBNAME=$(basename "$f" | sed 's/\.so.*//' | sed 's/^lib//')
      if ! jq -e ".components[] | select(.name | test(\"$LIBNAME\"; \"i\"))" sbom.json > /dev/null 2>&1; then
        echo "::warning::Vendored binary $f not found in SBOM"
      fi
    done
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Incomplete SBOMs create blind spots that allow compromised vendored code to evade detection |

**Alert you will see:** "Vulnerability found in component not present in SBOM"

Most organizations treat the SBOM as compliance truth. If the SBOM says "no log4j," the check passes. But the container may still contain log4j as a vendored JAR, shaded dependency, or transitive inclusion.

**Triage steps:**

1. Compare the vulnerability scanner's finding against all three SBOM sources
2. If no SBOM tool found the component, check if it's vendored (`find /vendor/ /third-party/ /lib/`)
3. Verify the CVE by checking the actual binary version
4. Add the component to the SBOM manually and update the enrichment process

---

## What You Learned

1. **No SBOM tool finds everything**: syft, trivy, and cdxgen on the same image produce different component lists.
2. **Vendored compiled code is invisible to SBOM tools**: a `.so` copied into the image won't be detected from package metadata.
3. **Complement SBOMs with direct vulnerability scanning**: scan the artifact itself, not just the SBOM.

## Further Reading

- [Anchore: Why SBOMs Are Not Enough](https://anchore.com/blog/why-sboms-are-not-enough/)
- [OWASP Dependency-Track](https://dependencytrack.org/)
- [Grype: A Vulnerability Scanner for Container Images](https://github.com/anchore/grype)
