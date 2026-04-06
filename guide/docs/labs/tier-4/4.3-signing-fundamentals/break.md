# Lab 4.3: Signing Fundamentals

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Unsigned Artifacts Are Accepted by Default

**Goal:** Deploy an unsigned image and see that nothing stops you.

### Step 1: Deploy the unsigned image

```bash
kubectl run test-unsigned --image=registry:5000/weaklink-app:unsigned
kubectl get pods
```

The pod starts. No warnings, no errors, no admission control.

### Step 2: Verify it's actually running

```bash
kubectl logs test-unsigned
kubectl exec test-unsigned -- cat /app/version.txt
```

From the cluster's perspective, there is zero difference between a signed and unsigned image.

### Step 3: The default state

Docker, Kubernetes, and cloud registries all accept any image by default. Signing is opt-in at every layer. If you sign but don't enforce verification, an attacker can push unsigned malicious images that deploy just as easily.

### Step 4: Clean up

```bash
kubectl delete pod test-unsigned
```
