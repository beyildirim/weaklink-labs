# Lab 3.2: Tag Mutability Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Tags Are Mutable Pointers

### Step 1: Inspect the current tag

```bash
crane digest registry:5000/webapp:1.0.0
```

Save the content-addressable SHA256 digest:

```bash
crane digest registry:5000/webapp:1.0.0 > /app/safe-digest.txt
cat /app/safe-digest.txt
```

### Step 2: Verify the running deployment

```bash
kubectl get deployment webapp -o jsonpath='{.spec.template.spec.containers[0].image}'
```

The deployment references `registry:5000/webapp:1.0.0`. A tag, not a digest.

### Step 3: Test the running app

```bash
kubectl exec deploy/webapp -- cat /app/version.txt
```

### Step 4: Understand the risk

If anyone pushes a new image to `registry:5000/webapp:1.0.0`, the next pod restart pulls it. Kubernetes does not verify image content matches what was originally deployed.

With `imagePullPolicy: Always` (default for `:latest`, common in production), every pod restart triggers a fresh pull.
