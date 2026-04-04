# Hint 2: Hardening Cloud CI/CD Services

## Fix 1: Scope SSM Parameter Access

Replace broad SSM access with specific parameter paths:

```json
{
  "Effect": "Allow",
  "Action": "ssm:GetParameter",
  "Resource": [
    "arn:aws:ssm:us-east-1:123456789:parameter/build/npm-token",
    "arn:aws:ssm:us-east-1:123456789:parameter/build/registry-url"
  ],
  "Condition": {
    "StringEquals": {
      "aws:ResourceTag/Environment": "build"
    }
  }
}
```

**Key principle:** Build-time secrets live under `/build/*`. Production secrets live under `/prod/*`. The build role can ONLY access `/build/*`.

## Fix 2: Validate Cloud Build Substitutions

Never pass substitution variables into shell commands or `--build-arg` without validation:

```yaml
# cloudbuild.yaml -- HARDENED
steps:
  - name: 'gcr.io/cloud-builders/docker'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        # Validate substitution -- alphanumeric and hyphens only
        if [[ ! "${_IMAGE_NAME}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
          echo "ERROR: Invalid image name: ${_IMAGE_NAME}"
          exit 1
        fi
        docker build -t "gcr.io/$PROJECT_ID/${_IMAGE_NAME}" .
substitutions:
  _IMAGE_NAME: 'my-app'
options:
  substitution_option: 'ALLOW_LOOSE'  # Changed to MUST_MATCH for prod
```

## Fix 3: Least-Privilege Build Roles

Compare the vulnerable and hardened IAM policies in `src/`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BuildArtifacts",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::build-artifacts-bucket/*"
    },
    {
      "Sid": "ECRPush",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "arn:aws:ecr:us-east-1:123456789:repository/my-app"
    },
    {
      "Sid": "DenyEverythingElse",
      "Effect": "Deny",
      "Action": [
        "iam:*",
        "sts:AssumeRole",
        "organizations:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Detection Queries

```spl
# CloudTrail: detect SSM parameter access during CodeBuild
index=cloudtrail eventName="GetParameter" userAgent="*codebuild*"
| rex field=requestParameters "name\":\"(?<param_path>[^\"]+)"
| where NOT match(param_path, "^/build/")
| eval severity="critical"
| table _time, sourceIPAddress, param_path, userIdentity.arn
```
