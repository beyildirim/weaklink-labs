To defend against the three GitLab CI attack vectors:

1. **Replace `include:remote`** with `include:project` to pull templates
   only from trusted internal repositories:
   ```yaml
   include:
     - project: 'security/ci-templates'
       file: '/templates/build.yml'
       ref: 'main'
   ```

2. **Mark sensitive variables as "Protected"** so they are only available
   to pipelines running on protected branches (not merge requests):
   ```yaml
   variables:
     DEPLOY_TOKEN:
       value: ""
       description: "Deployment token"
       # Set as Protected in GitLab UI: Settings > CI/CD > Variables
   ```

3. **Restrict cross-project triggers** by requiring a dedicated trigger
   token and validating the source project:
   ```yaml
   rules:
     - if: $CI_PIPELINE_SOURCE == "pipeline" && $CI_PROJECT_PATH == "team/trusted-repo"
   ```

Apply the hardened configuration:

```bash
cp /lab/src/hardened-gitlab-ci.yml /repos/wl-webapp/.gitlab-ci.yml
```
