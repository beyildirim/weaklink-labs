GitLab CI has three features that create unique attack surface compared
to GitHub Actions:

1. **`include:remote`** -- pulls CI templates from any URL. If that URL
   is attacker-controlled or compromised, your entire pipeline is owned.

2. **CI/CD variables** -- can be set at project, group, or instance level.
   If a variable is NOT marked "protected," it is available to every
   pipeline, including merge request pipelines from forks.

3. **`trigger:`** -- allows one project's pipeline to trigger another
   project's pipeline. If the triggered project has more privileges,
   this is a lateral movement path.

Examine the vulnerable configuration:

```bash
cat /repos/acme-webapp/.gitlab-ci.yml
```

Look for `include:remote` URLs, unprotected variable references,
and `trigger:` blocks that cross project boundaries.
