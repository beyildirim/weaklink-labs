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

## Close The Namespace Exemption Gap

### Step 1: Remove the unnecessary exemption

```bash
cat > /app/gatekeeper-config/config.yaml << 'EOF'
apiVersion: config.gatekeeper.sh/v1alpha1
kind: Config
metadata:
  name: config
  namespace: gatekeeper-system
spec:
  sync:
    syncOnly:
      - group: ""
        version: "v1"
        kind: "Pod"
      - group: "apps"
        version: "v1"
        kind: "Deployment"
  match:
    - excludedNamespaces: ["kube-system", "gatekeeper-system"]
      processes: ["*"]
EOF
kubectl apply -f /app/gatekeeper-config/config.yaml
```

Keep the system namespaces the lab already needs, but remove the monitoring exemption so attackers cannot hide there.

### Step 2: Delete the bypassed pod and retry the same attack

```bash
kubectl delete pod -n monitoring privileged-miner
kubectl apply -f /app/exploits/exempt-namespace-pod.yaml
```

The same manifest should now be rejected because the privileged pod no longer lands in an excluded namespace.

### Step 3: Audit the excluded namespace list deliberately

```bash
kubectl get config.config.gatekeeper.sh -n gatekeeper-system -o yaml 2>/dev/null
kubectl get clusterpolicies -o yaml | grep -A 10 "exclude"
```

Every excluded namespace is a policy exception. Keep that list short, explicit, and reviewed.

### Step 4: Add a simple policy review check for config changes

```bash
mkdir -p /app/policies/conftest
cat > /app/policies/conftest/test.rego << 'EOF'
package main

deny[msg] {
  input.kind == "Config"
  input.spec.match[_].excludedNamespaces[_] == "monitoring"
  msg := "monitoring must not be excluded from admission policy"
}
EOF
```

This does not replace runtime policy. It just prevents the exemption from quietly creeping back in through config drift.
