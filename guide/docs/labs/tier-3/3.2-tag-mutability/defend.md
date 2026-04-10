# Lab 3.2: Tag Mutability Attacks

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

## Digest Pinning and Admission Control

### Defense 1: Restore the safe image

```bash
SAFE_DIGEST=$(cat /app/safe-digest.txt)
crane tag registry:5000/webapp@${SAFE_DIGEST} 1.0.0
```

### Defense 2: Pin by digest in the deployment

```bash
SAFE_DIGEST=$(cat /app/safe-digest.txt)

cat > /app/deploy/deployment.yml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
        - name: webapp
          image: registry:5000/webapp@${SAFE_DIGEST}
          imagePullPolicy: Always
EOF

kubectl apply -f /app/deploy/deployment.yml
kubectl rollout status deployment/webapp --timeout=60s
```

Now even if the tag is overwritten, the deployment pulls the exact digest.

### Defense 3: Verify the safe image is back

```bash
kubectl exec deploy/webapp -- cat /app/version.txt
```

### Defense 4: Admission controller

A Kyverno policy rejects any pod using a tag-only image reference:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-image-digest
spec:
  validationFailureAction: Enforce
  rules:
    - name: check-digest
      match:
        any:
          - resources:
              kinds: ["Pod"]
      validate:
        message: "Images must use digest references (@sha256:), not tags"
        pattern:
          spec:
            containers:
              - image: "*@sha256:*"
```
