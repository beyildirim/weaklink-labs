# Hint 2: Defending Serverless Functions

## Pin Layer Versions by ARN

Never reference a layer by name alone. Always use the full ARN with version number:

```yaml
# VULNERABLE: Layer can be updated by anyone with publish permissions
Layers:
  - arn:aws:lambda:us-east-1:123456789:layer:my-shared-utils

# SECURE: Pinned to specific version -- immutable reference
Layers:
  - arn:aws:lambda:us-east-1:123456789:layer:my-shared-utils:7
```

## Least-Privilege IAM for Functions

Most Lambda functions ship with wildly overprivileged roles. A function that reads from one DynamoDB table should not have `dynamodb:*` or `s3:*`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Query"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789:table/orders"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:us-east-1:123456789:*"
    }
  ]
}
```

## Dependency Confusion in Serverless Builds

Serverless deployment tools (SAM, Serverless Framework) run `pip install` or `npm install` during packaging. If your `requirements.txt` references an internal package without a `--index-url` pin, the build step pulls from public PyPI first:

```bash
# VULNERABLE: build step runs pip install with default index
pip install -r requirements.txt

# SECURE: explicitly set index URL and block public fallback
pip install -r requirements.txt \
    --index-url https://internal.pypi.corp.com/simple/ \
    --no-deps
```

## CloudWatch Monitoring

Set alarms for anomalous function behavior:

```
Function duration > 2x P99 baseline     -> Possible interception overhead
Function error rate spike                -> Malicious code may throw exceptions
Outbound network bytes > expected        -> Data exfiltration
Concurrent executions spike              -> Attacker running parallel exfil
```
