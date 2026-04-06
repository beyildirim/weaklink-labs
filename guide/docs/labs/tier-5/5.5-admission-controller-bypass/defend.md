# Lab 5.5: Kubernetes Admission Controller Bypass

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

## Closing Admission Controller Gaps

### Fix 1: Minimize namespace exemptions

```bash
cat > /app/policies/gatekeeper-config.yaml << 'EOF'
apiVersion: config.gatekeeper.sh/v1alpha1
kind: Config
metadata:
  name: config
  namespace: gatekeeper-system
spec:
  match:
    - excludedNamespaces: ["gatekeeper-system"]
      processes: ["*"]
EOF
kubectl apply -f /app/policies/gatekeeper-config.yaml
```

Only exempt the admission controller's own namespace. Use targeted exceptions for specific system workloads instead of blanket namespace exemptions.

### Fix 2: Cover all resource types

```bash
cat > /app/policies/catch-all-webhook.yaml << 'EOF'
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: catch-all-policy
webhooks:
  - name: catch-all.policy.example.com
    rules:
      - apiGroups: ["*"]
        apiVersions: ["*"]
        operations: ["CREATE", "UPDATE"]
        resources: ["*"]
        scope: "Namespaced"
    clientConfig:
      service:
        name: gatekeeper-webhook-service
        namespace: gatekeeper-system
        path: /v1/admit
    failurePolicy: Fail
    sideEffects: None
    admissionReviewVersions: ["v1"]
EOF
kubectl apply -f /app/policies/catch-all-webhook.yaml
```

`failurePolicy: Fail` means unreachable webhook blocks resources rather than allowing them through. `resources: ["*"]` catches CRDs.

### Fix 3: Detect post-admission drift

```bash
cat > /app/policies/audit-privileged.yaml << 'EOF'
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sDisallowedCapabilities
metadata:
  name: audit-privileged-containers
spec:
  enforcementAction: warn
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    disallowedCapabilities: ["ALL"]
EOF
kubectl apply -f /app/policies/audit-privileged.yaml

kubectl get constraint audit-privileged-containers -o yaml | grep -A 20 "violations"
```

Gatekeeper audit mode continuously checks running resources, catching resources that were compliant at creation but mutated afterward.

### Verify the defense

```bash
kubectl delete pod -n kube-system malicious-debug-pod --ignore-not-found
kubectl delete -f /app/attacks/uncovered-crd.yaml --ignore-not-found
kubectl delete -f /app/attacks/post-admission-mutation.yaml --ignore-not-found

weaklink verify 5.5
```
