# Hint 1: Understanding Cloud CI/CD Attack Surfaces

Cloud-native CI/CD services differ from GitHub Actions in critical ways. The attack surface is broader because these services deeply integrate with the cloud provider's IAM, secrets management, and resource APIs.

## Attack 1: CodeBuild Environment Variable Injection

AWS CodeBuild can pull environment variables from SSM Parameter Store. The `buildspec.yml` defines which parameters to fetch:

```yaml
# buildspec.yml -- VULNERABLE
version: 0.2
env:
  parameter-store:
    DB_PASSWORD: /prod/db/password      # Fetched at build time
    API_KEY: /prod/api/master-key       # Available as $API_KEY in build
phases:
  build:
    commands:
      - echo "Building with $DB_PASSWORD"  # Logged in plaintext!
      - npm run build
```

**The problem:** If the CodeBuild IAM role has `ssm:GetParameter` on `/prod/*`, ANY build in that project can fetch ANY production secret. A malicious PR that modifies `buildspec.yml` to reference `/prod/db/password` gets the secret during the build.

## Attack 2: Cloud Build Substitution Abuse

GCP Cloud Build allows substitution variables that can be user-controlled:

```yaml
# cloudbuild.yaml -- VULNERABLE
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/${_IMAGE_NAME}', '.']
substitutions:
  _IMAGE_NAME: 'my-app'
```

If `_IMAGE_NAME` is controllable via a trigger configuration or API call, an attacker can inject: `my-app --build-arg SECRET=$(cat /workspace/credentials.json)`.

## Attack 3: Overprivileged Build Roles

Look at the IAM role attached to the build service. If it has `AdministratorAccess` or broad `sts:AssumeRole`, the build can escalate to any AWS resource.

Start by examining the vulnerable configs in `src/` and identify the specific injection point in each.
