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

## Three Ways to Bypass Admission Controllers

### Bypass 1: Exempt namespaces

```bash
cat /app/attacks/exempt-namespace-pod.yaml
kubectl apply -f /app/attacks/exempt-namespace-pod.yaml
```

The privileged pod deploys in the exempt namespace. Admission controllers skip certain namespaces to avoid breaking system components.

```bash
kubectl get pod -n kube-system malicious-debug-pod
kubectl exec -n kube-system malicious-debug-pod -- whoami
kubectl exec -n kube-system malicious-debug-pod -- cat /proc/1/status | head -5
```

### Bypass 2: Uncovered Custom Resource Definitions

```bash
cat /app/attacks/uncovered-crd.yaml
kubectl apply -f /app/attacks/uncovered-crd.yaml
```

A custom resource type creates a workload functionally equivalent to a privileged pod, but no admission policy covers it. The webhook configuration only matches specific resource types.

```bash
kubectl get validatingwebhookconfigurations -o yaml | grep -A 3 "resources:"
```

### Bypass 3: Post-admission mutations

```bash
cat /app/attacks/post-admission-mutation.yaml
kubectl apply -f /app/attacks/post-admission-mutation.yaml
```

A CronJob patches existing deployments to add privileged security contexts. The initial deployment passes admission. The CronJob mutates it afterward. Admission controllers do not re-validate running workloads.

```bash
kubectl get pods -w --output-watch-events
```

### Combined impact

```bash
kubectl get pods --all-namespaces -o wide | grep -E "malicious|backdoor|debug"
```

Three privileged workloads running, all invisible to the admission controller dashboard showing "100% compliance."

> **Checkpoint:** You should have three bypassed workloads running: one in an exempt namespace, one via uncovered CRD, one via post-admission mutation.
