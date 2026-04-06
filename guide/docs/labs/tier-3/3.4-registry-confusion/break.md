# Lab 3.4: Registry Confusion

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

## Registry Confusion Attack

### Step 1: Examine the vulnerable deployment

```bash
cat /app/deploy/deployment.yml
```

Short image name like `myapp:latest` without a registry prefix. Docker must decide which registry to pull from.

### Step 2: Deploy the application

```bash
kubectl apply -f /app/deploy/deployment.yml
kubectl rollout status deployment/myapp --timeout=60s
```

### Step 3: Check which image was pulled

```bash
kubectl get pod -l app=myapp -o jsonpath='{.items[0].status.containerStatuses[0].imageID}'
```

Compare against both registries:

```bash
echo "Private registry digest: $(crane digest registry:5000/myapp:latest)"
echo "Attacker registry digest: $(crane digest attacker-registry:5000/myapp:latest)"
```

### Step 4: Verify the damage

```bash
kubectl exec deploy/myapp -- cat /app/version.txt
```

If "ATTACKER-CONTROLLED", the deployment pulled from the wrong registry due to search order priority.

### Step 5: Document the attack

```bash
cat > /app/findings.txt << 'EOF'
FINDING: Registry confusion attack successful.
The deployment used an unqualified image name "myapp:latest".
Docker resolved this to the attacker's registry due to search order priority.
Private registry digest: <private-digest>
Attacker registry digest: <attacker-digest>
Deployed digest matched the attacker's image.
EOF
```
