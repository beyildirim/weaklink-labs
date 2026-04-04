# Hint 2: Breaking IAM Trust Chains

## Add External ID Conditions

External IDs prevent the "confused deputy" problem. Each trust relationship requires a secret value that only legitimate callers know:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::222222222222:root"
    },
    "Action": "sts:AssumeRole",
    "Condition": {
      "StringEquals": {
        "sts:ExternalId": "ci-to-staging-7f3a9b2c"
      }
    }
  }]
}
```

## Use OIDC Federation Instead of Long-Lived Credentials

Replace IAM users and cross-account roles with OIDC federation. The CI system proves its identity via a JWT token, not via stored credentials:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::333333333333:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:myorg/myrepo:ref:refs/heads/main"
      }
    }
  }]
}
```

With OIDC, there are no long-lived credentials to steal. The trust relationship is scoped to a specific repository and branch.

## Add Source IP and Time-of-Day Conditions

```json
{
  "Condition": {
    "IpAddress": {
      "aws:SourceIp": "203.0.113.0/24"
    },
    "DateGreaterThan": {
      "aws:CurrentTime": "2026-01-01T08:00:00Z"
    },
    "DateLessThan": {
      "aws:CurrentTime": "2026-01-01T18:00:00Z"
    }
  }
}
```

## CloudTrail Detection

Look for the `AssumeRole` events in CloudTrail and check for anomalies:

```spl
index=cloudtrail eventName="AssumeRole"
| spath output=source_account path=userIdentity.accountId
| spath output=target_role path=requestParameters.roleArn
| rex field=target_role "arn:aws:iam::(?<target_account>\d+):role/(?<role_name>.+)"
| stats count by source_account, target_account, role_name
| where source_account != target_account
| sort -count
```

Flag any cross-account role assumption from an account that has not historically assumed that role.
