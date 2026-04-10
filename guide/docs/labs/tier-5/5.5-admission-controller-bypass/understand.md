# Lab 5.5: Kubernetes Admission Controller Bypass

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

## How Admission Controllers Enforce Policy

### Step 1: Explore the admission pipeline

```bash
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations
```

Validating webhooks reject non-compliant resources. Mutating webhooks modify resources to enforce defaults.

### Step 2: Examine the installed policies

```bash
# OPA Gatekeeper
kubectl get constraints
kubectl get constrainttemplates

# Kyverno
kubectl get clusterpolicies
kubectl get policies --all-namespaces
```

### Step 3: See what the policies enforce

```bash
kubectl get constrainttemplates k8srequirenonprivileged -o yaml
kubectl get config.config.gatekeeper.sh -n gatekeeper-system -o yaml
```

The Gatekeeper config syncs only Pods and Deployments, so CRDs and post-admission drift are not covered yet.

### Step 4: Map the coverage gap

```bash
cat /app/gatekeeper-config/config.yaml
ls /app/exploits/
```

Notice the monitoring namespace exemption. That is the primary gap this lab will exploit.

### Step 5: Check which namespaces are covered

```bash
kubectl get validatingwebhookconfigurations -o yaml | grep -A 5 "namespaceSelector"
kubectl get config.config.gatekeeper.sh -n gatekeeper-system -o yaml 2>/dev/null
kubectl get clusterpolicies -o yaml | grep -A 10 "exclude"
```

Note which namespaces are excluded. These are your attack surface.
