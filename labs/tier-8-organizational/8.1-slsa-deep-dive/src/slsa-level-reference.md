# SLSA Level Quick Reference

## Level 0: No Guarantees
- No provenance
- No build requirements
- This is the default state of most software

## Level 1: Provenance Exists
- The build process is documented (not just "run this script on my laptop")
- Build provenance is generated, describing how the artifact was produced
- Provenance is available to downstream consumers
- **Key question:** Can someone see *how* this artifact was built?

## Level 2: Hosted Build Platform
- Builds run on a hosted service (GitHub Actions, GitLab CI, Jenkins, etc.)
- Provenance is generated *by the build service*, not by the build script itself
- Provenance is signed by the build service
- Provenance includes the build configuration source and source revision
- **Key question:** Can someone verify the build platform *authenticated* the provenance?

## Level 3: Hardened Builds
- Build environment is isolated (containers, VMs, ephemeral runners)
- Provenance cannot be falsified by the build tenants (the users of the build service)
- Builds are isolated from one another (no shared mutable state)
- Source of the build definition is verified
- **Key question:** Could a compromised build *forge* its own provenance? (At L3, the answer is no.)

## Level 4: Hermetic + Reproducible + Two-Party Review
- All build inputs are fully declared; no network access during build (hermetic)
- Builds are reproducible: same inputs produce identical outputs
- All source changes require review by two independent parties
- Build service itself is hardened against insider threats
- **Key question:** Is this build *independent* of any single person or system?

---

## Common CI/CD Mapping

| CI/CD Feature | SLSA Relevance |
|---------------|----------------|
| GitHub Actions / GitLab CI hosted runners | Supports Level 2 (hosted build) |
| OIDC-based keyless signing (Sigstore) | Supports Level 2-3 (signed, unforgeable provenance) |
| Container-based build isolation | Supports Level 3 (isolated builds) |
| slsa-github-generator | Directly produces SLSA Level 3 provenance on GitHub |
| Bazel with remote caching disabled | Supports Level 4 (hermetic builds) |
| Branch protection + required reviewers | Supports Level 4 (two-party review) |
| Reproducible builds (deterministic toolchains) | Supports Level 4 |

---

## Provenance Predicate Example (SLSA v1.0)

```json
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [
    {
      "name": "weaklink-app",
      "digest": { "sha256": "abc123..." }
    }
  ],
  "predicateType": "https://slsa.dev/provenance/v1",
  "predicate": {
    "buildDefinition": {
      "buildType": "https://slsa-framework.github.io/github-actions-buildtypes/workflow/v1",
      "externalParameters": {
        "workflow": {
          "ref": "refs/heads/main",
          "repository": "https://github.com/org/weaklink-app"
        }
      },
      "internalParameters": {
        "github": {
          "runner_id": "12345",
          "event_name": "push"
        }
      },
      "resolvedDependencies": [
        {
          "uri": "git+https://github.com/org/weaklink-app@refs/heads/main",
          "digest": { "gitCommit": "def456..." }
        }
      ]
    },
    "runDetails": {
      "builder": {
        "id": "https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@refs/tags/v1.9.0"
      },
      "metadata": {
        "invocationId": "https://github.com/org/weaklink-app/actions/runs/789"
      }
    }
  }
}
```
