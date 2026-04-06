# Lab 3.4: Registry Confusion

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

## Fully Qualified Names and Registry Allowlists

### Defense 1: Use fully qualified image names

```bash
cat > /app/deploy/deployment.yml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: registry:5000/myapp:latest
          imagePullPolicy: Always
EOF

kubectl apply -f /app/deploy/deployment.yml
kubectl rollout status deployment/myapp --timeout=60s
```

No ambiguity. Docker knows exactly which registry to pull from.

### Defense 2: Verify the correct image is running

```bash
kubectl exec deploy/myapp -- cat /app/version.txt
```

### Defense 3: Create a registry allowlist policy

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-registries
spec:
  validationFailureAction: Enforce
  rules:
    - name: allowed-registries
      match:
        any:
          - resources:
              kinds: ["Pod"]
      validate:
        message: "Images must come from approved registries: registry:5000"
        pattern:
          spec:
            containers:
              - image: "registry:5000/*"
```

### Defense 4: Combine with digest pinning

For the strongest defense, use fully qualified names with digest pinning:

```yaml
image: registry:5000/myapp@sha256:<digest>
```

Eliminates both registry confusion and tag mutability.

### Step 5: Verify the lab

```bash
weaklink verify 3.4
```
