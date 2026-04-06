# Lab 9.2: Serverless Supply Chain

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

**Goal:** Pin layer versions, scope IAM, isolate networks, fix the dependency pipeline.

## Fix 1: Pin Lambda Layer versions by ARN

```yaml
# VULNERABLE:
Layers:
  - arn:aws:lambda:us-east-1:999888777666:layer:shared-utils

# HARDENED:
Layers:
  - arn:aws:lambda:us-east-1:123456789012:layer:shared-utils:7
```

## Fix 2: Least-privilege IAM

```json
{
  "Statement": [
    {"Effect": "Allow", "Action": ["dynamodb:GetItem", "dynamodb:Query"],
     "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/orders"},
    {"Effect": "Allow", "Action": ["sns:Publish"],
     "Resource": "arn:aws:sns:us-east-1:123456789012:order-notifications"}
  ]
}
```

Blast radius goes from "entire account" to "one DynamoDB table and one SNS topic."

## Fix 3: VPC isolation

```yaml
VpcConfig:
  SecurityGroupIds:
    - sg-0123456789abcdef0
  SubnetIds:
    - subnet-private-1a
    - subnet-private-1b
```

No internet access. DynamoDB and SNS accessed via VPC endpoints.

## Fix 4: Fix the dependency pipeline

```bash
--index-url https://internal.pypi.corp.com/simple/
--no-deps
wl-order-utils==1.2.3
wl-notification-client==2.1.0
```

## Fix 5: Build layers internally

Build and publish your own layers from verified dependencies instead of trusting third-party layers.

## Final verification

```bash
weaklink verify 9.2
```
